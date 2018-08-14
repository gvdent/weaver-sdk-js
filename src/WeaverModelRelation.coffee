cuid        = require('cuid')
Promise     = require('bluebird')
Weaver      = require('./Weaver')
_           = require('lodash')
cjson       = require('circular-json')

class WeaverModelRelation extends Weaver.Relation

  _getClassName: (node) ->
    node.className

  # Check if relation is allowed according to definition
  _checkCorrectClass: (node) ->
    defs = []
    if node instanceof Weaver.ModelClass or node instanceof Weaver.DefinedNode 
      defs = node.getDefinitions()
    else
      return

    found = @owner.getToRanges(@modelKey, node)
    allowed = @owner.getRanges(@modelKey)
    return true if found? and found.length > 0
    throw new Error("Model #{@className} is not allowed to have relation #{@modelKey} to #{node.id()}"+
                    " of def #{JSON.stringify(defs)}, allowed ranges are #{JSON.stringify(allowed)}")

  _checkCorrectConstructor: (ctor) ->
    allowed = false
    @owner.getRanges(@modelKey).map((range)=>
      try
        keys = range.split(':')
        modelName = keys[0]
        className = keys[1]
        if @model.modelMap[modelName][className] is ctor
          allowed = true
    )
    return true if allowed
    throw new Error("Model #{@className} is not allowed to have relation #{@modelKey} to instance"+
      " of def #{ctor.className}.")

  add: (node, relId, addToPendingWrites = true) ->
    @_checkCorrectClass(node)
    super(node, relId, addToPendingWrites)

  update: (oldNode, newNode) ->
    @_checkCorrectClass(newNode)
    super(oldNode, newNode)


  load: (constructor)->
    @_checkCorrectConstructor(constructor)
    super(constructor)

module.exports = WeaverModelRelation
