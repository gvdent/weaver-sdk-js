# Libs
io       = require('socket.io-client')
Promise  = require('bluebird')
pjson    = require('../package.json')
ss       = require('socket.io-stream')

class SocketController

  constructor: (@address, @options) ->
    defaultOptions =
      reconnection: true
      rejectUnauthorized: true

    @options = @options or defaultOptions
    @options.reconnection = true
    @options.query = "sdkVersion=#{pjson.version}&requiredServerVersion=#{pjson.com_weaverplatform.requiredServerVersion}&requiredConnectorVersion=#{pjson.com_weaverplatform.requiredConnectorVersion}"

  connect: ->
    new Promise((resolve, reject) =>
      @io = io.connect(@address, @options)
      @io.on('connect', ->
        resolve()
      ).on('connect_error', ->
        reject('connect_error')
      ).on('connect_timeout', ->
        reject('connect_timeout')
      ).on('error', (err) ->
        reject(err or 'error')
      )
    )

  emit: (key, body) ->
    new Promise((resolve, reject) =>
      ss(@io).emit(key, body, (response) ->
        if response.code? and response.message?
          reject(new Error(response.message, response.code))
        else if response is 0
          resolve()
        else
          resolve(response)
      )
    )

  GET: (path, body) ->
    @emit(path, body)

  POST: (path, body) ->
    @emit(path, body)

  STREAM: (path, body) ->
    @emit(path, body)

module.exports = SocketController
