define(['underscore', 'backbone', 'lib/turncoat/Factory','uuid'], (_, Backbone, Factory, UUID)->

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      #super(attributes, options)
      if !@get("uuid")?
        @set("uuid", UUID())

    toString:()->
      GameStateModel.marshaller.marshalState(@)

    searchChildren:(modelChecker, deep)->
      recRes = []
      for gsmAtt of @attributes when @attributes[gsmAtt] instanceof GameStateModel
        gsm = @attributes[gsmAtt]
        recRes = recRes.concat(gsm.searchChildren(modelChecker))
        if (!modelChecker? || modelChecker(gsm)) then recRes.push(gsm)
      recRes


  )
  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    @marshaller.unmarshalState(state)


  GameStateModel
)