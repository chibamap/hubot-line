tunnel = require 'tunnel'
https = require 'https'
Promise = require 'bluebird'

TO_CHANNEL = 1383378250
EVENT_TYPE_SEND = "138311608800106203"
CONTENT_TYPE =
  TEXT: 1

# Line Api
module.exports = class Api
  constructor: (@options) ->
    @logger = @options.logger
    @logger.debug 'api initialize:' + JSON.stringify @options
    if @options.proxy
      @tunnelAg = tunnel.httpsOverHttp
        proxy:
          host: @options.proxy.host,
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
  _post: (path, data) ->
    self = @
    new Promise (resolve, reject) ->
      req = self._request('POST', path)
      req.on 'response', (res)->
        unless res.statusCode == 200
          self._request_failed res
          reject
        else
          self.logger.debug 'send success'
          resolve
      req.end JSON.stringify data

  # send get request
  _get: (path) ->
    self = @
    new Promise (resolve) ->
      req = self._request 'GET', path
      req.on 'response', (res)->
        unless res.statusCode == 200
          self._request_failed res
          reject
        else
          self.logger.debug 'send success'
          resolve res

  # generate request object
  _request: (method, path) ->
    opts =
      path: path
      method: method
      hostname: 'trialbot-api.line.me'
      headers:
        'Content-Type': 'application/json; charser=UTF-8'
        'X-Line-ChannelID': @options.channel_id
        'X-Line-ChannelSecret': @options.channel_secret
        'X-Line-Trusted-User-With-ACL': @options.mid

    if @options.proxy
      opts.agent = @tunnelAg

    req = https.request opts
    req.on "error", (e) -> self._request_failed e.message

  _request_failed: (res) ->
    @logger.error "Received status code #{res.statusCode}"
