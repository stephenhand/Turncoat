define(['underscore', 'backbone', 'lib/turncoat/Factory'], (_, Backbone, Factory)->

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      #super(attributes, options)

    toString:()->
      GameStateModel.marshaller.marshalState(@)

  )
  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    @marshaller.unmarshalState(state)


  GameStateModel
)