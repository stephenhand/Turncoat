define(['underscore', 'backbone', 'lib/turncoat/Factory','uuid'], (_, Backbone, Factory, UUID)->

  recursiveSearch = (item, checker, deep)->
    if (typeof checker is "boolean")
      deep = checker
      checker = null
    deep ?= true
    recRes = []
    searchSet
    if item instanceof Backbone.Model
      searchSet = (item.attributes[searchItem] for searchItem of item.attributes when item.attributes[searchItem] instanceof Backbone.Model or item.attributes[searchItem] instanceof Backbone.Collection)
    else if item instanceof Backbone.Collection
      searchSet = (searchItem for searchItem in item.models when searchItem instanceof Backbone.Model or searchItem instanceof Backbone.Collection)
    else throw new Error("Only Backbone.Models and Backbone.Collections support recursiveSearch")

    for setItem in searchSet
      if deep then recRes = recRes.concat(recursiveSearch(setItem, checker))
      if (!checker? || checker(setItem)) then recRes.push(setItem)
    recRes

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      #super(attributes, options)
      if !@get("uuid")?
        @set("uuid", UUID())

    toString:()->
      GameStateModel.marshaller.marshalState(@)

    searchChildren:(modelChecker, deep)->
      recursiveSearch(@, modelChecker, deep)

    searchGameStateModels:(modelChecker, deep)->
      recursiveSearch(@, (model)->
        (model instanceof GameStateModel) and (!modelChecker? or modelChecker(model))
      , deep)



  )

  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    @marshaller.unmarshalState(state)


  GameStateModel
)