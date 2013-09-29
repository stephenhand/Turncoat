define(["underscore", "uuid", "backbone", "lib/turncoat/Factory", "lib/turncoat/LogEntry", "lib/turncoat/GameHeader"], (_, UUID, Backbone, Factory, LogEntry, GameHeader)->

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
      if !@id?
        @id=UUID()

    toString:()->
      if (!GameStateModel.marshaller?)
        throw new Error("State Marshaller not state, set a default state marshaller before constructing GSMs youi plan to marshal.")
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

    logEvent:(moment, eventName, eventDetails)->
      GameStateModel.logEvent(@, moment, eventName, eventDetails)

    getLatestEvent:(name)->
      if @get("_eventLog")?
        @get("_eventLog").find((l)->(!name? || name is l.get("name")))

    getHeaderForUser:(@userId)->
      header = new GameHeader(
        id:@get("id")
        label:@get("label")
        created:@getLatestEvent("CREATED")?.get("timestamp")
        lastActivity:@getLatestEvent()?.get("timestamp")
      )
      header.set("userStatus", player.get("user")?.get("status")) for player in @get("players")?.models ? [] when player.get("user")?.get("id") is userId
      header
  )

  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    GameStateModel.marshaller.unmarshalState(state)

  GameStateModel.logEvent = (gsm, moment, eventName, eventDetails)->
    if !gsm.get("_eventLog")? then gsm.set("_eventLog", new Backbone.Collection([]))
    gsm.get("_eventLog").unshift(
      new LogEntry(
        timestamp:moment
        name:eventName
        details:eventDetails
      )
    )

  GameStateModel.vivifier = (unvivified, constructor)->
    vivified = new constructor()
    vivified.set(unvivified)
    vivified.unset("_type")
    vivified._type = undefined
    vivified

  GameStateModel
)