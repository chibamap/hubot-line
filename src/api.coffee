tunnel = require 'tunnel'
request = require 'request'
Promise = require 'bluebird'

TO_CHANNEL = 1383378250
EVENT_TYPE_SEND = "138311608800106203"
CONTENT_TYPE =
  TEXT: 1
LINEAPI_BASEURL = 'https://trialbot-api.line.me/'

# Line Api
module.exports = class Api
  constructor: (@options) ->
    @logger = @options.logger
    if @options.proxy
      @tunnelAg = tunnel.httpsOverHttp
        proxy:
          host: @options.proxy.host
          port: @options.proxy.url
          proxyAuth: @options.proxy.auth

  # send message
  send: (to, content) ->
    data =
      to: [to]
      toChannel: TO_CHANNEL
      eventType: EVENT_TYPE_SEND
      content: content
    @_post '/v1/events', data

  # send text message
  sendText: (to, text) ->
    content =
      contentType: CONTENT_TYPE.TEXT
      toType: 1,
      text: text
    @send to, content

  # send post request
  _post: (url, data) ->
    self = @
    new Promise (resolve, reject) ->
      self._request.post url, (e, res, body) ->
        self.logger.info e
        unless res.statusCode == 200
          self._request_failed e, res
          reject res
        else
          self.logger.debug 'send success'
          resolve res
      req.end JSON.stringify data

  # send get request
  _get: (url) ->
    self = @
    new Promise (resolve, reject) ->
      self._request.get url, (e, res, body) ->
        unless res.statusCode == 200
          self._request_failed e, res
          reject()
        else
          self.logger.debug 'send success'
          resolve body

  # generate request object
  _request: ->
    self = @
    req = request.defaults
      proxy: @options.proxy.href
      baseUrl: LINEAPI_BASEURL
      headers:
        'Content-Type': 'application/json; charser=UTF-8'
        'X-Line-ChannelID': @options.channel_id
        'X-Line-ChannelSecret': @options.channel_secret
        'X-Line-Trusted-User-With-ACL': @options.mid

  _request_failed: (e, res) ->
    @logger.error e.message
    @logger.error e.stack
    @logger.error "Received status code #{res.statusCode}"
