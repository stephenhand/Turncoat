define(["uuid","underscore", "jquery", "backbone","moment", "lib/turncoat/Factory", "lib/turncoat/GameStateModel", "text!data/manOWarGameTemplates.txt", "text!data/config.txt"], (UUID, _, $, Backbone, moment, Factory, GameStateModel, templatesListText, configText)->
  CURRENT_GAMES = "current-games"

  class LocalStoragePersister
    constructor:(marshaller)->
      @marshaller = marshaller ? Factory.buildStateMarshaller()
      _.extend(@, Backbone.Events)
      $(window).on("storage",(event)=>
        keyParts = event.originalEvent.key.split("::")
        switch keyParts[0]
          when CURRENT_GAMES
            if keyParts.length is 2 then @trigger("gameListUpdated",
              userId:keyParts[1]
              list:@marshaller.unmarshalModel(event.originalEvent.newValue)
            )

      )

    loadUser:(id)->
      if !id? then throw new Error("Must specify a player id.")
      return new Backbone.Model(id:id)

    loadGameTemplateList:(type, user)->
      new Backbone.Collection(
        for gameTemplate in @marshaller.unmarshalModel(templatesListText).models
          id:gameTemplate.get("id")
          label:gameTemplate.get("label")
          players:gameTemplate.get("players")?.length

      )

    loadGameTemplate:(id)->
      template = _.find(@marshaller.unmarshalModel(templatesListText).models,(t)->t.get("id") is id)
      if (!template?) then throw new Error("Failed to load listed template")
      GameStateModel.fromString(
        @marshaller.marshalModel(template)
      )

    loadGameTypes:()->
      @marshaller.unmarshalModel(configText).get("gameTypes")


    loadGameList:(user, type)->
      if (!user?)
        throw new ReferenceError("User must be specified")
      storedVal = window.localStorage.getItem(CURRENT_GAMES+"::"+user)
      if !storedVal
        return null
      if (!type)
        @marshaller.unmarshalState(window.localStorage.getItem(CURRENT_GAMES+"::"+user))
      else
        filtered = (game for game in @marshaller.unmarshalState(window.localStorage.getItem(CURRENT_GAMES+"::"+user)).models when !type? or game.get("type") is type)
        new Backbone.Collection(filtered)


    loadGameState:(user, id)->
      if (!id?) then throw new Error("Must specify a game id to retrieve it from storage")
      json = window.localStorage.getItem(CURRENT_GAMES+"::"+user+"::"+id)
      if json? then GameStateModel.fromString(json) else null

    saveGameState:(user, state)->
      if (!user? or !state?) then throw new Error("Must specify user id and state to save a game")
      listJSON = window.localStorage.getItem(CURRENT_GAMES+"::"+user)
      list=new Backbone.Collection()
      if (listJSON?) then list = @marshaller.unmarshalState(listJSON)
      newListItem = state.getHeaderForUser(user)


      list.add(
        newListItem
      ,
        merge:true
      )
      window.localStorage.setItem(CURRENT_GAMES+"::"+user,@marshaller.marshalState(list))
      window.localStorage.setItem(CURRENT_GAMES+"::"+user+"::"+state.get("id"), state.toString())

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

