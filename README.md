You can try it here
```
https://newshortenlink.herokuapp.com/
```
Or try it locally
```
git clone
undle install
change base_url `"https://newshortenlink.herokuapp.com/"` to `"http://localhost:4567/"` in shortlink_app.rb &
change `https://newshortenlink.herokuapp.com/` to `http://localhost:4567/` in index.erb
redis-server
ruby shortlink_app.rb
And you will see a result here: http://localhost:4567/
```

You can use it with API like
```
GET: curl https://newshortenlink.herokuapp.com/api/v1/short/gu3yk

POST: curl -i -H "Content-Type: application/json" -X POST https://newshortenlink.herokuapp.com/api/v1/full.json?long_url=www.nnm.me
```