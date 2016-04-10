# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response, User} = require 'hubot'
express = require 'express'
bodyParser = require 'body-parser'
crypto = require 'crypto'
url = require 'url'
HTTP = require 'https'
EventEmitter = require('events').EventEmitter

EVENT_TYPE_POST = '138311608800106203'
TO_CHANNEL = 1383378250
CONTENT_TYPE =
  TEXT: 1

class Line extends Adapter
  constructor: (@robot)->
    super @robot
    @logger = robot.logger
    fixieUrl = url.parse process.env.FIXIE_URL
    @options =
      channel_id:     process.env.HUBOT_LINE_CHANNEL_ID
      channel_secret: process.env.HUBOT_LINE_CHANNEL_SECRET
      mid:            process.env.HUBOT_LINE_MID
      fixie_url: fixieUrl
      logger: @logger

  # send message
  send: (envelope, strings...) ->
    self = @
    user = envelope.user
    headers = @commonHeaders 'POST', '/v1/events'
    data =
      to: [user.id]
      toChannel: TO_CHANNEL
      eventType: EVENT_TYPE_POST
      content:
        contentType: CONTENT_TYPE.TEXT,
        toType:1,
        text: JSON.stringify strings
    request = HTTP.request headers, (response) ->
      unless response.statusCode == 200
        self.request_failed "Received status code #{response.statusCode}"
      else
        self.logger.debug 'send success'

    request.on "error", (e) -> self.request_failed e.message
    request.end JSON.stringify data

  reply: (envelope, strings...) ->
    @robot.logger.debug "Reply" + JSON.stringify strings

  run: ->
    self = @
    @logger.info "Run"
    @emit "connected"

    @listener = new Listener @options

    @listener.on 'connected', ->
      self.emit "connected"
      @logger.debug "Sending connected event"

    @listener.on 'message', (content) ->
      @logger.debug 'received message ' + content.text
      user = new User content.from, name: 'test'
      message = new TextMessage user, content.text, content.id
      self.receive message

  commonHeaders: (method, path) ->
    opts =
      host: @options.fixie_url.hostname
      path: path
      method: method
      headers:
        Host: 'trialbot-api.line.me'
        "Proxy-Authorization": "Basic " + new Buffer(@options.fixie_url.auth).toString('base64'),
        'Content-Type': 'application/json; charser=UTF-8'
        'X-Line-ChannelID': @options.channel_id
        'X-Line-ChannelSecret': @options.channel_secret
        'X-Line-Trusted-User-With-ACL': @options.mid

  request_failed: (message) ->
    @logger.error "Sending message failed!"
    @logger.error message

exports.use = (robot) ->
  new Line robot

#
# listener
#

EVENT_TYPE =
  MESSAGE: '138311609000106303'
  OPERATION: '138311609100106403'

class Listener extends EventEmitter
  constructor: (@options, @robot) ->
    self = @
    @logger = @options.logger
    app = express()
    app.use bodyParser.json()

    app.post '/callback', (req, res)->
      self.callback req
      res.send 'ok'

    app.get '/healthcheck', (req, res) ->
      res.send 'ok'

    port = process.env.PORT || 5000
    app.use express.static(__dirname + '/public')
    app.listen port, ->
      self.logger.info "Node app is running at localhost:" + port

  validate: (req) ->
    hash = crypto.createHmac 'sha256', @options.channel_secret
      .update req.body
      .digest 'base64'
    hmac = req.get 'X-LINE-CHANNELSIGNATURE'
    hash is hmac

  callback: (req) ->
    for i, rec of req.body.result
      switch rec.eventType
        when EVENT_TYPE.MESSAGE
          @emit 'message', rec.content
        else
          @emit 'operation', rec.content
