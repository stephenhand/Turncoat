define(['underscore', 'backbone', 'sprintf', 'UI/component/ObservingViewModelCollection', 'AppState', 'state/Player'], (_, Backbone, sprintf, BackboneViewModelCollection, AppState, Player)->

  CreateGameViewModel = Backbone.Model.extend(
    initialize:()->
      @gameTypes=new BackboneViewModelCollection( )
      @gameTypes.watch([AppState.get("currentUser").get("gameTemplates")])

      @gameTypes.onSourceUpdated=()=>
        @gameTypes.updateFromWatchedCollections(
          (item , watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
          (watched)->
            new Backbone.Model(
              id:watched.get("id")
              label:sprintf("%s (%s players)", watched.get("label"), watched.get("players"))
              players:watched.get("players")
            )
        )

      @gameTypes.onSourceUpdated()

      @selectedGameType = new Backbone.Model()
      @selectedGameType.on("change:id", ()=>
        @selectedGameType.set("template",AppState.loadGameTemplate(@selectedGameType.get("id")))
        playerList = new Backbone.Collection(
          for player in @selectedGameType.get("template").get("players").models
            new Player(
              id:player.get("id")
              name:player.get("name")
              description:player.get("description")
            )
        )
        @selectedGameType.set("playerList", playerList)
        @selectUsersPlayer( @selectedGameType.get("template").get("players").at(0).get("id"))
      )
      @selectedGameType.set("id",@gameTypes.at(0)?.get("id"))

      @gameSetupTypes=new BackboneViewModelCollection( )
      @gameSetupTypes.watch([AppState.get("gameTypes")])

      @gameSetupTypes.onSourceUpdated=()=>
        @gameSetupTypes.updateFromWatchedCollections(
          (item , watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
          (watched)->
            new Backbone.Model(watched.attributes)
        )

      @gameSetupTypes.onSourceUpdated()

      @selectedGameSetupType = new Backbone.Model( )
      @selectedGameSetupType.on("change:id", ()=>
        @selectedGameSetupType.set("setup",@gameSetupTypes.find(
          (item)=>
            item.get("id") is @selectedGameSetupType.get("id")
        ))
      )
      @selectedGameSetupType.set("id", @gameSetupTypes.at(0)?.get("id"))
      @confirmCreateGameClicked=()=>
        userIds=[]
        for player in @selectedGameType.get("playerList").models
          if !(player.get("user")?.get("id"))? or userIds[player.get("user").get("id")] then return false
          userIds[player.get("user").get("id")] = true
        @selectedGameType.get("template").set("users", new Backbone.Collection(
            for listPlayer in @selectedGameType.get("playerList").models when listPlayer.get("user")?
              user = listPlayer.get("user")
              user.set("playerId",listPlayer.get("id"))
              user
          )
        )
        AppState.createGameFromTemplate(@selectedGameType.get("template"))


    selectUsersPlayer:(id)->
      for player in @selectedGameType.get("playerList").models
        if player.get("id") is id
          player.set("selectedForUser", true)
          player.set("user",
            new Backbone.Model(id:AppState.get("currentUser").get("id")))
        else
          if player.get("selectedForUser") is true then player.set("user", new Backbone.Model())
          player.unset("selectedForUser")

  )


  CreateGameViewModel
)

