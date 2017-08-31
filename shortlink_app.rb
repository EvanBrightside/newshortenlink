require 'sinatra'
require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/async'
require 'open-uri'
require 'em-hiredis'
require 'eventmachine'
require 'pry'
require 'json'
require 'redis'
require 'thin'

def run(opts)
  EM::run do
    server  = opts[:server] || 'thin'
    host    = opts[:host]   || '0.0.0.0'
    port    = opts[:port]   || '8181'
    web_app = opts[:app]

    @@redis = EM::Hiredis.connect

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    unless ['thin', 'hatetepe', 'goliath'].include? server
      raise "Need an EM webserver, but #{server} isn't"
    end

    Rack::Server.start({
      app:    dispatch,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })
  end
end

class ShortLinkApp < Sinatra::Base
  register Sinatra::Async
  register Sinatra::Namespace

  configure do
    set :threaded, false
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  def random_string(length)
    rand(36**length).to_s(36)
  end

  def link(full_url)
    if !full_url.nil?
      u = URI.parse(full_url)
      (!u.scheme) ? link = "http://" + full_url : link = full_url
    end
  end

  get '/' do
    erb :index
  end

  apost '/' do
    if params[:url] and not params[:url].empty?
      @longUrl = random_string 5
      @@redis.set("#{@longUrl}", params[:url]).tap do |d|
        d.callback do |full_url|
          body { erb :index }
        end
        d.errback { |e| err }
      end
    end
  end

  aget '/:longUrl' do
    @@redis.get("#{params[:longUrl]}").callback { |full_url|
      async_schedule { redirect link(full_url) || "/" }
    }
  end

  base_url = "http://localhost:8181/"

  apost '/api/v1/full.json' do
    content_type :json
    short_code = random_string 5
    @@redis.set("#{short_code}", params[:long_url]).callback {

      body { {"url": base_url+short_code}.to_json }
    }
  end

  aget '/api/v1/short/:url' do |url|
    @@redis.get(url).callback { |full_url|
      body { link(full_url) }
    }
  end
end

run(app: ShortLinkApp.new)
