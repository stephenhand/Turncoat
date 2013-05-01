define(['underscore', 'backbone', 'lib/turncoat/Factory','uuid'], (_, Backbone, Factory, UUID)->

  recurseChildren = (item, processor, deep, earlyOut)->
    deep ?= true
    recRes = []
    searchSet
    if item instanceof Backbone.Model
      searchSet = (item.attributes[searchItem] for searchItem of item.attributes when item.attributes[searchItem] instanceof Backbone.Model or item.attributes[searchItem] instanceof Backbone.Collection)
    else if item instanceof Backbone.Collection
      searchSet = (searchItem for searchItem in item.models when searchItem instanceof Backbone.Model or searchItem instanceof Backbone.Collection)
    else throw new Error("Only Backbone.Models and Backbone.Collections support recursiveSearch")

    for setItem in searchSet
      if deep then recurseChildren(setItem, processor)
      earlyOut = {byRef:false}
      processor(setItem, earlyOut)
      if earlyOut.byRef then break


  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      if !@get("uuid")?
        @set("uuid", UUID())

    toString:()->
      GameStateModel.marshaller.marshalState(@)

    searchChildren:(checker, deep)->
      if (typeof checker is "boolean")
        deep = checker
        checker = null
      recRes = []
      recurseChildren(@, (item)->
        if (!checker? || checker(item)) then recRes.push(item)
      , deep)
      recRes

    searchGameStateModels:(modelChecker, deep)->
      @searchChildren((model)->
        (model instanceof GameStateModel) and (!modelChecker? or modelChecker(model))
      , deep)

    getOwnershipChain:(root)->
      chain = []
      root.searchChildren((model, earlyOut)=>
        if model is @ or chain.length
          chain.push(model)
          if earlyOut? then earlyOut.byRef = true
      , true)
      if (chain.length) then chain.push(root) else chain = null
      chain
  )

  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    @marshaller.unmarshalState(state)


  GameStateModel
)