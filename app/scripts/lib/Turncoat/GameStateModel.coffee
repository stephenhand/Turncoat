define(["underscore", "uuid", "moment",  "backbone", "lib/backboneTools/ModelProcessor", "lib/turncoat/Constants", "lib/turncoat/Factory", "lib/turncoat/LogEntry", "lib/turncoat/GameHeader"], (_, UUID, moment, Backbone, ModelProcessor, Constants, Factory, LogEntry, GameHeader)->

  GameStateModel = Backbone.Model.extend(
    initialize:(attributes, options)->
      GameStateModel.marshaller ?= Factory.buildStateMarshaller()
      if !@id?
        @id=UUID()


    toString:()->
      if (!GameStateModel.marshaller?)
        throw new Error("State Marshaller not set, set a default state marshaller before constructing GSMs you plan to marshal.")
      GameStateModel.marshaller.marshalState(@)

    searchChildren:(checker, deep)->
      if (typeof checker is "boolean")
        deep = checker
        checker = null
      recRes = []
      ModelProcessor.recurse(@, (item)=>
        if (@ isnt item and (!checker? || checker(item))) then recRes.push(item)
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
          true
      , true)
      if (chain.length) then chain.push(root) else chain = null
      chain

    generateEvent:(eventName, eventData)->
      validation = new Backbone.Model(
        counter:0
      )
      previousTimestamp = null
      previousId = null
      if @get("_eventLog")? && !@get("_eventLog").isEmpty()
        l = @get("_eventLog").at(0)
        validation.set("counter", @get("_eventLog").length)
        validation.set("previousTimestamp", l.get("timestamp"))
        validation.set("previousId", l.get("id"))
      new LogEntry(
        id:UUID()
        timestamp:moment.utc()
        name:eventName
        data:eventData
        validation:validation
      )

    logEvent:(event)->
      GameStateModel.logEvent(@, event)

    getLatestEvent:(name)->
      if @get("_eventLog")?
        @get("_eventLog").find((l)->(!name? || name is l.get("name")))

    getHeaderForUser:(@userId)->
      header = new GameHeader(
        id:@get("id")
        label:@get("label")
        created:@getLatestEvent(Constants.LogEvents.GAMECREATED)?.get("timestamp")
        lastActivity:@getLatestEvent()?.get("timestamp")
      )
      userStatus = undefined
      allReady = true
      for u in @get("users")?.models ? []
        if u.get("status") isnt Constants.READY_STATE then allReady = false
        if u.get("id") is userId then userStatus = u.get("status")
      if allReady && userStatus? then userStatus = Constants.PLAYING_STATE
      header.set("userStatus",userStatus)
      header
  )

  GameStateModel.fromString = (state)->
    GameStateModel.marshaller ?= Factory.buildStateMarshaller()
    GameStateModel.marshaller.unmarshalState(state)

  GameStateModel.logEvent = (gsm, event)->
    if !gsm.get("_eventLog")?
      gsm.set("_eventLog", new Backbone.Collection([]))
    gsm.get("_eventLog").unshift(event)

  GameStateModel.vivifier = (unvivified, constructor)->
    vivified = new constructor()
    vivified.set(unvivified)
    vivified.unset("_type")
    vivified._type = undefined
    vivified

  GameStateModel
)