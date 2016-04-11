EventEmitter = require 'events' .EventEmitter

EVENT_TYPE =
  MESSAGE: '138311609000106303'
  OPERATION: '138311609100106403'

module.exports = class Listener extends EventEmitter
  constructor: (@options, @robot) ->
    self = @
    @logger = @options.logger

    @robot.router.post @options.endpoint, (req, res) ->
      self.callback req
      res.send 'ok'

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
