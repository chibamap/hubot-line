# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response, User} = require 'hubot'
express = require 'express'
bodyParser = require 'body-parser'
crypto = require 'crypto'

http = require 'http'
# callback = require './callback'

HTTPS        = require 'https'
EventEmitter = require('events').EventEmitter

# {Listener} = require './listener'

class Line extends Adapter
  constructor: (@robot)->
    super @robot
    @logger = robot.logger

  # send message
  send: (envelope, strings...) ->
    @robot.logger.info "Send"

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    self = @
    @logger.info "Run"
    @emit "connected"

    @options =
      channel_secret: process.env.HUBOT_LINE_CHANNEL_SECRET
      logger: @logger

    @listener = new Listener @options

    @listener.on 'connected', ->
      self.emit "connected"
      @logger.debug "Sending connected event"

    @listener.on 'message', (content) ->
      @logger.debug 'received message ' + content.text
      user = new User content.from, name: 'test'
      message = new TextMessage user, content.text, content.id
      self.receive message

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
