You can try it here
```
https://newshortenlink.herokuapp.com/
```
Or try it locally
```
git clone https://github.com/EvanBrightside/newshortenlink.git

bundle install

redis-server

thin start

And you will see a result here: http://localhost:3000/
```

You can use it with API like
```
GET: curl https://newshortenlink.herokuapp.com/api/v1/short/gu3yk

POST: curl -i -H "Content-Type: application/json" -X POST https://newshortenlink.herokuapp.com/api/v1/full.json?long_url=www.nnm.me
```
