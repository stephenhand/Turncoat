

define(["underscore", "backbone", "lib/turncoat/Constants", "lib/turncoat/Game", "lib/turncoat/User", "UI/component/ObservingViewModelItem", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "UI/widgets/GameListViewModel", "AppState"], (_, Backbone, Constants, Game, User, ObservingViewModelItem, ObservingViewModelCollection, ObservableOrderCollection, GameListViewModel, AppState)->


  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new GameListViewModel())
      @set("challengePlayerList", new ObservingViewModelCollection())

      @get("tab")?.on("change:active", (model)=>
        if !model.get("active") then @get("challenges").selectGame()
      )
      @get("challenges").on("selectedChallengeChanged", (id)=>
        challengePlayers = @get("challengePlayerList")
        if @get("selectedChallenge")?.get("users")?
          challengePlayers.stopListening(@get("selectedChallenge").get("users"))
        challengePlayers.unwatch(true)
        if id?
          @set("selectedChallenge",AppState.loadGame(id))
          selectedChallenge = @get("selectedChallenge")
          if selectedChallenge?
            challengePlayers.watch([selectedChallenge.get("players")])
            rcvm = @

            remapUsers = (players)->

              for player in players.models
                listUsers = selectedChallenge.get("users").where(playerId:player.get("id"))
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
                        remapUsers(challengePlayers)
                      else
                        player.get("user").set("status",m.get("status"))
                        if player.get("user").get("id") is AppState.get("currentUser").get("id")
                          rcvm.set("selectedChallengeUserStatus", player.get("user").get("status"))
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
                    rcvm.set("selectedChallengeUserStatus", player.get("user").get("status"))
                  else
                    player.set("selectedForUser",false)

            challengePlayers.onSourceUpdated=()->
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
                  ovmi.onModelUpdated = (model, attribute)->
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
              currentPlayer = challengePlayers?.find((p)->p.get("user")?.get("id") is AppState.get("currentUser").get("id"))
              if currentPlayer?
                currentPlayer.set("selectedForUser",true)
                rcvm.set("selectedChallengeUserStatus", currentPlayer.get("user").get("status"))
              else
                rcvm.unset("selectedChallengeUserStatus")
            challengePlayers.onSourceUpdated()
            remapAllUsers = ()->
              remapUsers(challengePlayers)
            challengePlayers.listenTo(selectedChallenge.get("users"), "add", remapAllUsers, @)
            challengePlayers.listenTo(selectedChallenge.get("users"), "remove", remapAllUsers, @)
            challengePlayers.listenTo(selectedChallenge.get("users"), "reset", remapAllUsers, @)
        else
          @unset("selectedChallenge")
      )
    selectChallenge:(gameId)->
      @get("challenges").selectGame(gameId)

    issueChallenge:(id)->
      if (!id?) then throw new Error("Cannot send challenge, user identifier missing.")
      AppState.issueChallenge(id, @get("selectedChallenge"))

    acceptChallenge:()->
      AppState.acceptChallenge(@get("selectedChallenge"))
  )


  ReviewChallengesViewModel
)

