hubot line adapter
--

# Status

draft.

# for test snippet

curl -v -X POST \
-H "Content-type: application/json;charset=UTF-8" \
-H "X-LINE-ChannelSignature: /xZcekiWAiCrwq5dC+wBwBf6gQ33i1jRAo01KAVO3/U=" \
 -d '{ "result": { "from":"u206d25c2ea6bd87c17655609a1c37cb8", "fromChannel":"1341301815","to":["u0cc15697597f61dd8b01cea8b027050e"],"toChannel":"1441301333",  "eventType":"138311609000106303","id":"ABCDEF-12345678901","content": {} } }' \
 http://localhost:5000/callback
