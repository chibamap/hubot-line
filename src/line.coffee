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
    super
    @robot.logger.info

  # send message
  send: (envelope, strings...) ->
    @robot.logger.info "Send"

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    self = @
    @robot.logger.info "Run"
    @emit "connected"
    @robot.receive message
    @options =
      chanel_secret: process.env.HUBOT_LINE_CHANNEL_SECRET
    @listener = new Listener @options

    @listener.on 'connected', ->
      self.emit "connected"
    @listener.on 'message', (id, content) ->
      console.log 'received any message from stream'

exports.use = (robot) ->
  new Line robot

EVENT_TYPE =
  MESSAGE: '138311609000106303'
  OPERATION: '138311609100106403'

class Listener extends EventEmitter
  constructor: (options, @robot) ->
    self = @
    app = express()
    app.use bodyParser.json()

    app.post '/callback', (req, res)->
      console.log 'received any...'
      self.callback req
      res.send 'ok'

    app.get '/healthcheck', (req, res) ->
      res.send 'ok'

    port =  process.env.PORT || 5000
    app.use express.static(__dirname + '/public')
    app.listen port, ->
      console.log "Node app is running at localhost:" + app.get 'port'

  validate: (req) ->
    # todo: validate request body here

  callback: (req) ->
    for i, rec of req.params.result
      switch rec.eventType
        when EVENT_TYPE.MESSAGE then @emit 'message', rec.id, rec.content
        else @emit 'operation', rec.id, rec.content
