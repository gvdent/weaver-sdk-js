# Libs
Promise  = require('bluebird')
pjson    = require('../package.json')
Weaver   = require('./Weaver')

class SocketController

  constructor: (@address, @options) ->
    defaultOptions =
      reconnection: true
      rejectUnauthorized: true

    @options = @options or defaultOptions
    @options.reconnection = true
    @options.query = "sdkVersion=#{pjson.version}&requiredServerVersion=#{pjson.com_weaverplatform.requiredServerVersion}&requiredConnectorVersion=#{pjson.com_weaverplatform.requiredConnectorVersion}"

  requireIO: ->
    require('socket.io-client/dist/socket.io')

  connect: ->
    new Promise((resolve, reject) =>
      @io = @requireIO().connect(@address, @options)

      @io.on('socket.shout', (msg) ->
        Weaver.publish('socket.shout', msg)
      )

      @io.on('connect', =>
        resolve()
      ).on('connect_error', (err) ->
        reject(err or 'connect_error')
      ).on('connect_timeout', ->
        reject('connect_timeout')
      ).on('error', (err) ->
        reject(err or 'error')
      )
    )

  disconnect: ->
    @io.disconnect()

  parseBody: (body) ->
    JSON.stringify(body)

  getSocket: (body) ->
    @io

  emit: (key, body) ->
    new Promise((resolve, reject) =>
      emitStart = Date.now()
      socket = @getSocket(body)
      body   = @parseBody(body)

      socket.emit(key, body, (response) =>
        if response.code? and response.message?
          error = new Error(response.message)
          error.code = response.code
          reject(error)
        else if response is 0
          resolve()
        else
          resolve(response)
        if (response.times?)
          @_calculateTimestamps(response, emitStart, Date.now())
        response
      )
    )

  _calculateTimestamps: (response, emitStart, emitEnd) ->

    sdkToServer  = response.times.serverStart - emitStart
    innerServerDelay = response.times.serverStartConnector - response.times.serverStart
    serverToConn = response.times.executionTimeStart - response.times.serverStartConnector
    connToServer = response.times.serverEnd - response.times.processingTimeEnd
    serverToSdk  = emitEnd - response.times.serverEnd

    response.totalTime = emitEnd - emitStart
    response.times = {
      'sdkToServer': sdkToServer,
      'innerServerDelay': innerServerDelay,
      'serverToConn': serverToConn,
      'connToServer': connToServer,
      'serverToSdk': serverToSdk,
      'executionTime': response.times.executionTime,
      'subQueryTime': response.times.subQueryTime, # never set
      'processingTime': response.times.processingTime,
    }

    response

  GET: (path, body) ->
    @emit(path, body)

  POST: (path, body) ->
    @emit(path, body)

module.exports = SocketController
