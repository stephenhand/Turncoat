define(['uuid','underscore', 'backbone', "lib/turncoat/Factory", "lib/turncoat/GameStateModel", 'text!data/manOWarGameTemplates.txt', 'text!data/config.txt'], (UUID, _, Backbone, Factory, GameStateModel, templatesListText, configText)->


  class LocalStoragePersister
    loadUser:(id)->
      if !id? then throw new Error("Must specify a player id.")
      return new Backbone.Model(id:id)

    loadGameTemplateList:(type, user)->
      new Backbone.Collection(
        for gameTemplate in JSON.parse(templatesListText)
          id:gameTemplate.id
          label:gameTemplate.label
          players:gameTemplate.players?.length

      )

    loadGameTemplate:(id)->
      template = _.find(JSON.parse(templatesListText),(t)->t.id is id)
      if (!template?) then throw new Error("Failed to load listed template")
      GameStateModel.fromString(
        JSON.stringify(
          template
        )
      )

    loadGameTypes:()->
      new Backbone.Collection(
        JSON.parse(configText).gameTypes
      )

    loadGameList:(user, type)->
      if (!user?)
        throw new ReferenceError("User must be specified")
      if !window.localStorage.getItem(user+"::current-games")
        return null
      for game in JSON.parse(window.localStorage.getItem(user+"::current-games")) when !type? or game._type is type
        new Backbone.Model(
          label:game.label
          id:game.id
          type:game._type
        )

    loadGameState:(user, id)->
      if (!id?) then throw new Error("Must specify a game id to retrieve it from storage")
      json = window.localStorage.getItem(user+"::current-games::"+id)
      if json? then GameStateModel.fromString(json) else null

    saveGameState:(user, state)->
      if (!user? or !state?) then throw new Error("Must specify user id and state to save a game")
      listJSON = window.localStorage.getItem(user+"::current-games")
      list=[]
      if (listJSON?) then list = JSON.parse(listJSON)

      list.push(
        label:state.get("label")
        id:state.get("id")
        type:state.get("_type")
      )
      window.localStorage.setItem(user+"::current-games",JSON.stringify(list))
      window.localStorage.setItem(user+"::current-games::"+state.get("id"), state.toString())

    loadPendingGamesList:(user, filter)->
      if (!user?) then throw new Error("User must be specified")
      if !window.localStorage.getItem(user+"::pending-games")
        return null
      for invite in JSON.parse(window.localStorage.getItem(user+"::pending-games")) when !filter? or ((!filter.type? or invite.type is filter.type) and (!filter.status? or invite.status is filter.status))
        invite.time = new Date(invite.time)
        new Backbone.Model(
          invite
        )


  Factory.registerPersister("LocalStoragePersister",LocalStoragePersister)

  LocalStoragePersister
)

