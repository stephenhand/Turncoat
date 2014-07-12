define(['underscore', 'backbone'], (_, Backbone)->
  reverse = []
  TypeRegistry =

    registerType:(typeName, prototype)->
      @[typeName] = prototype
      reverse[prototype] = typeName
    reverseLookup:(prototype)->
      reverse[prototype]

  TypeRegistry
)