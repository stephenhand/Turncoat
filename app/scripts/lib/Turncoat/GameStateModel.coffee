define(['underscore', 'backbone', 'lib/turncoat/Factory','uuid'], (_, Backbone, Factory, UUID)->

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      #super(attributes, options)
      if !@get("uuid")?
        @set("uuid", UUID())

    toString:()->
      GameStateModel.marshaller.marshalState(@)

  )
  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    @marshaller.unmarshalState(state)


  GameStateModel
)