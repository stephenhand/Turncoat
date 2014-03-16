define(["underscore", "backbone", "UI/component/ObservingViewModelCollection", "UI/component/ObservingViewModelItem", "AppState"], (_, Backbone, ObservingViewModelCollection, ObservingViewModelItem, AppState)->
  class PlayerListViewModel extends ObservingViewModelCollection
    initialize:()->
      super()

    watch:(game)->
      super([game.get("players")])
      superUnwatch = @unwatch
      @currentGame = game
      remapUsers = (players)=>
        for player in players.models
          listUsers = game.get("users").where(playerId:player.get("id"))
          if (listUsers.length>1) then throw new Error("Cannot map multiple users to one player")
          listUser = listUsers[0]
          player.get("user")?.unwatch()
          if !listUser?
            player.unset("user")
          else
            if !player.get("user")?
              player.set(
                "user",
                new ObservingViewModelItem(
                  id:listUser.get("id")
                  status:listUser.get("status")
                )
              )
              player.get("user").onModelUpdated = (m)->
                if m.get("id") isnt player.get("user").get("id")
                  remapUsers(@)
                else
                  player.get("user").set("status",m.get("status"))
                  if player.get("user").get("id") is AppState.get("currentUser").get("id")
                    @trigger("currentUserStatusUpdate", player.get("user").get("status"))
            else
              player.get("user").set(
                id:listUser.get("id")
                status:listUser.get("status")
              )
            player.get("user").watch([
              model:listUser
              attributes:["id","status"]
            ])
            if player.get("user").get("id") is AppState.get("currentUser").get("id")
              player.set("selectedForUser",true)
              @trigger("currentUserStatusUpdate", player.get("user").get("status"))
            else
              player.set("selectedForUser",false)

      @onSourceUpdated=()->
        @updateFromWatchedCollections(
          (item, watched)->
            item.get("id")? and item.get("id") is watched.get("id")
        ,
          (input)->
            ovmi=new ObservingViewModelItem(
              id:input.get("id")
              name:input.get("name")
              description:input.get("description")
            )
            ovmi.onModelUpdated = (model)->
              ovmi.set(
                name:model.get("name")
                description:model.get("description")
              )
            ovmi.watch([
              model:input
              attributes:[
                "name",
                "description"
              ]
            ])
            remapUsers(new Backbone.Collection([ovmi]))
            ovmi
        ,
          undefined
        ,
          (removed)->
            removed.unwatch()
            removed.get("user")?.unwatch()
        )
        currentPlayer = @find((p)->p.get("user")?.get("id") is AppState.get("currentUser").get("id"))
        if currentPlayer?
          currentPlayer.set("selectedForUser",true)
          @trigger("currentUserStatusUpdate", currentPlayer.get("user").get("status"))
        else
          @trigger("currentUserStatusUpdate")
      @onSourceUpdated()
      remapAllUsers = ()=>
        remapUsers(@)
      @listenTo(game.get("users"), "add", remapAllUsers, @)
      @listenTo(game.get("users"), "remove", remapAllUsers, @)
      @listenTo(game.get("users"), "reset", remapAllUsers, @)

      @unwatch= ()->
        if @currentGame?.get("users")?
          @stopListening(@currentGame.get("users"))
        @currentGame = null
        superUnwatch(true)


    unwatch:()->




  PlayerListViewModel
)

