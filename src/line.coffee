# Hubot dependencies
{Robot, Adapter, TextMessage, Response, User} = require 'hubot'
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
    user = envelope.user
    @api.sendText user.id, strings.shift()

  run: ->
    self = @
    @api = new Api @options
    @listener = new Listener @robot, @options

    @listener.on 'message', (content) ->
      @logger.debug "message from: [#{content.from}]"
      user = self.robot.brain.userForId content.from, room: 'room'
      message = new TextMessage user, content.text, content.id
      self.receive message

    @listener.listen()
    @emit "connected"

exports.use = (robot) ->
  new Line robot
