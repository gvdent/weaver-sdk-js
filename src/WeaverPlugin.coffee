Weaver      = require('./Weaver')
CoreManager = Weaver.getCoreManager()

class WeaverPlugin

  constructor: (serverObject) ->
    @._name        = serverObject.name
    @._version     = serverObject.version
    @._author      = serverObject.author
    @._description = serverObject.description
    @._functions   = serverObject.functions

    # Parse functions that will be accessible from @
    serverObject.functions.forEach((f) =>
      @[f.name] = (args...) ->

        # Build payload from arguments based on function require
        payload = {}
        payload[r] = args[index] for r, index in f.require

        # Execute by route and payload
        CoreManager.executePluginFunction(f.route, payload)
    )

  # Load given plugin from server
  @load: (name) ->
    CoreManager.getPlugin(name)

  # Parse plugin functions for easy reading
  printFunctions: ->

    # Example: The function add with require x and y becomes add(x,y)
    prettyFunction = (f) ->
      args = ""
      args += r + "," for r in f.require
      args = args.slice(0, -1) # Remove last comma
      "#{f.name}(#{args})"

    (prettyFunction(f) for f in @_functions)

  getPluginName: ->
    @_name

  getPluginVersion: ->
    @_version

  getPluginAuthor: ->
    @_author

  getPluginDescription: ->
    @_description

  @list: ->
    CoreManager.listPlugins()

module.exports = WeaverPlugin
