define(['underscore', 'backbone', 'lib/Factory'], (_, Backbone, Factory)->

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()

      #super(attributes, options)



    toString:()->
      GameStateModel.marshaller.marshalState(@)

  )
  GameStateModel.fromString = (state)->
    @marshaller.unmarshalState(state)


  GameStateModel
)