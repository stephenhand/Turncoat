define(['underscore', 'backbone'], (_, Backbone)->
  StateRegistry =
    reverse:[]
    registerType:(typeName, constructor)->
      @[typeName] = constructor
      @reverse[constructor] = typeName



  StateRegistry
)