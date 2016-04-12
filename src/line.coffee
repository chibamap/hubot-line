# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response, User} = require 'hubot'
url = require 'url'

Api = require './api'
Listener = require './listener'

# Hubot Line adapter
class Line extends Adapter
  constructor: (@robot) ->
    super @robot
    @logger = @robot.logger
    @options =
      channel_id:     process.env.HUBOT_LINE_CHANNEL_ID
      channel_secret: process.env.HUBOT_LINE_CHANNEL_SECRET
      mid:            process.env.HUBOT_LINE_MID
      endpoint:       process.env.HUBOT_ENDPONT || '/callback'
      logger:         @logger
      proxy:          url.parse process.env.FIXIE_URL

  # send message
  send: (envelope, strings...) ->
    @logger.debug 'Send:' + JSON.stringify strings
    user = envelope.user
    @api.sendText user.id, strings

  reply: (envelope, strings...) ->
    @robot.logger.debug "Reply" + JSON.stringify strings

  run: ->
    self = @
    @api = new Api @options
    @listener = new Listener @options
    @robot.router.all @options.endpoint, @listener.router()

    @listener.on 'connected', ->
      self.emit "connected"

    @listener.on 'message', (content) ->
      @logger.debug 'received message ' + content.text
      user = new User content.from, room: 'room'
      message = new TextMessage user, content.text, content.id
      self.receive message

exports.use = (robot) ->
  new Line robot
