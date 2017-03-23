Weaver      = require('./Weaver')
CoreManager = Weaver.getCoreManager()



class WeaverHistory

  constructor: () ->



  forUser: (userId)->
    @users = [userId]
  forUsers: (userIds)->
    @users = userIds

  fromDateTime: (pattern)->
    @fromDateTime = pattern

  beforeDateTime: (pattern)->
    @beforeDateTime = pattern

  getHistory: (idField, keyField, toField)->
    typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
    ids = if typeIsArray idField then idField else [idField]
    keys = if typeIsArray keyField then keyField else [keyField] if keyField?
    tos = if typeIsArray toField then toField else [toField] if toField?
    CoreManager.getHistory({ids, keys, tos, @fromDateTime, @beforeDateTime, @users})

# Export
module.exports = WeaverHistory
