# dependencies
express = require 'express'
{EventEmitter} = require "events"

# defines
EVENT_TYPE =
  MESSAGE: '138311609000106303'
  OPERATION: '138311609100106403'

# listener
class Listener extends EventEmitter
  constructor: (@options) ->
    self = @
    @logger = @options.logger
    @_router = express.Router()

    @_router.all '*', (req) ->
      self.logger.debug req.body
      for i, rec of req.body.result
        switch rec.eventType
          when EVENT_TYPE.MESSAGE
            self.emit 'message', rec.content
          else
            self.logger.debug 'skip unless messsage'

  router: ->
    @_router

  validate: (req) ->
    hash = crypto.createHmac 'sha256', @options.channel_secret
      .update req.body
      .digest 'base64'
    hmac = req.get 'X-LINE-CHANNELSIGNATURE'
    hash is hmac

module.exports = Listener
