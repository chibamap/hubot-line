# dependencies
express = require 'express'
bodyParser = require('body-parser')

{EventEmitter} = require "events"

# defines
EVENT_TYPE =
  MESSAGE: '138311609000106303'
  OPERATION: '138311609100106403'

# listener
class Listener extends EventEmitter
  constructor: (@robot, @options) ->
    @logger = @options.logger

  listen: ->
    self = @
    @robot.router.post @options.endpoint, (req, res) ->
      for i, rec of req.body.result
        switch rec.eventType
          when EVENT_TYPE.MESSAGE
            self.emit 'message', rec.content
          else
            self.logger.debug 'skip unless messsage'
      res.send 'ok'

  validate: (req) ->
    hash = crypto.createHmac 'sha256', @options.channel_secret
      .update req.body
      .digest 'base64'
    hmac = req.get 'X-LINE-CHANNELSIGNATURE'
    hash is hmac

module.exports = Listener
