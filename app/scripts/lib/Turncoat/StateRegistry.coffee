define(['underscore', 'backbone'], (_, Backbone)->
  reverse = []
  StateRegistry =

    registerType:(typeName, prototype)->
      @[typeName] = prototype
      reverse[prototype] = typeName
    reverseLookup:(prototype)->
      reverse[prototype]

  StateRegistry
)