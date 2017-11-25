class WeaverModelValidator

  constructor: (@definition) ->

  validate: ->
    for className of @definition.classes
      # Set nulls to {}
      @definition.classes[className] = @definition.classes[className] or {}
      classDefinition = @definition.classes[className]

      # Check if super is available
      if classDefinition.super?
        superDefinition = @definition.classes[classDefinition.super]
        if not superDefinition?
          throw new Error("Super class #{classDefinition.super} for #{className} could not be found in the definition.")

      # Check if range in relations exist
      for key, relation of classDefinition.relations when relation?.range?
        for range in relation.range
          if not @definition.classes[range]?
            throw new Error("Range #{range} in relation #{className}.#{key} could not be found in the definition.")


module.exports = WeaverModelValidator
