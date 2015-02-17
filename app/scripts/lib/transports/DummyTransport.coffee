define(["underscore", "backbone"], (_, Backbone)->
  class DummyTransport
    constructor:(opt)->
      _.extend(@, Backbone.Events)

    broadcastGameEvent:(recipients, data)=>
      @trigger("eventReceived", data)

    startListening:()->
    stopListening:()->
  Factory.registerTransport("DummyTransport",DummyTransport)

  DummyTransport
)

