define(["underscore", "backbone", "lib/turncoat/Factory"], (_, Backbone, Factory)->
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

