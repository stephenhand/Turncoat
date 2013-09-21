define(['underscore', 'backbone'], (_, Backbone)->
  StateRegistry =
    reverse:[]
    registerType:(typeName, factory)->
      @[typeName] = factory
      @reverse[factory] = typeName



  StateRegistry
)