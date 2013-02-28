define(['underscore', 'backbone'], (_, Backbone)->
  StateRegistry =
    registerType:(typeName, constructor)->
      @[typeName] = constructor


  StateRegistry
)