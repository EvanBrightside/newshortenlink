require 'sinatra'
require 'open-uri'
require 'em-hiredis'
require 'eventmachine'
require 'sinatra/namespace'
require 'pry'
require 'erb'
require 'json'

configure do
  require 'redis'
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
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

post '/' do
  if params[:url] and not params[:url].empty?
    @longUrl = random_string 5
    REDIS.set "#{@longUrl}", params[:url]
  end
  erb :index
end

get '/:longUrl' do
  full_url = REDIS.get "#{params[:longUrl]}"
  redirect link(full_url) || '/'
end

namespace '/api/v1' do
  base_url = "https://newshortenlink.herokuapp.com/"

  post '/full.json' do
    content_type :json
    short_code = random_string 5
    REDIS.set "#{short_code}", params[:long_url]
    { url: base_url+short_code }.to_json
  end

  get '/short/:url' do |url|
    link(REDIS.get(url))
  end
end
