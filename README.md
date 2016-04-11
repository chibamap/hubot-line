hubot line adapter
--

# Status

draft.

# set up

```
heroku config:set HUBOT_HEROKU_KEEPALIVE_URL=$(heroku apps:info -s | grep web-url | cut -d= -f2)healthcheck
heroku config:set HUBOT_LINE_CHANNEL_ID={your LINE channel id}
heroku config:set HUBOT_LINE_CHANNEL_SECRET={your LINE channel secret}
heroku config:set HUBOT_LINE_MID={your LINE mid}
```


heroku addons:create fixie:tricycle

git push heroku master

# test snippet

```
curl -v -X POST \
-H "Content-type: application/json;charset=UTF-8" \
-H "X-LINE-ChannelSignature: /xZcekiWAiCrwq5dC+wBwBf6gQ33i1jRAo01KAVO3/U=" \
 -d '{ "result": [{ "from":"u206d25c2ea6bd87c17655609a1c37cb8", "fromChannel":"1341301815","to":["u0cc15697597f61dd8b01cea8b027050e"],"toChannel":"1441301333",  "eventType":"138311609000106303","id":"ABCDEF-12345678901","content": {"location":null,"id":"325708", "contentType":1, "from":"uff2aec188e58752ee1fb0f9507c6529a","createdTime":1332394961610,"to":["u0a556cffd4da0dd89c94fb36e36e1cdc"],"toType":1,"contentMetadata":null,"text":"Hello, BOT API Server!"  } }] }' \
 http://localhost:5000/callback
```
