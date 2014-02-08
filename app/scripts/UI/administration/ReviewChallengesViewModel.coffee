

define(["setTimeout", "underscore", "backbone", "lib/turncoat/Constants", "lib/turncoat/Game", "lib/turncoat/User", "UI/component/ObservingViewModelItem", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "AppState"], (setTimeout, _, Backbone, Constants, Game, User, ObservingViewModelItem, ObservingViewModelCollection, ObservableOrderCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when Constants.READY_STATE
        "Waiting on other players to respond to the challenge."
      when Constants.CHALLENGED_STATE
        "A challenge awaiting your response."

  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new ObservingViewModelCollection())
      @set("challengePlayerList", new ObservingViewModelCollection())
      _.extend(@get("challenges"), ObservableOrderCollection)
      @get("challenges").setOrderAttribute("ordinal")
      @get("challenges").comparator=(a, b)->
        switch
          when !a.get("created")?.unix? && !b.get("created")?.unix? then 0
          when !a.get("created")?.unix? then 1
          when !b.get("created")?.unix? then -1
          when a.get("created").unix() > b.get("created").unix() then -1
          when a.get("created").unix() < b.get("created").unix() then 1
          else 0

      @get("challenges").watch([AppState.get("currentUser").get("games")])
      @listenTo(AppState, "change::currentUser", ()->
        @get("challenges").unwatch()
        @get("challenges").watch([AppState.get("currentUser").get("games")])
      ,@)
      @get("challenges").onSourceUpdated=()->
        @updateFromWatchedCollections(
          (item, watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
        ,
          (input)->
            newItem = new Backbone.Model(
              created:input.get("created")
              createdText:input.get("created")?.format?('MMMM Do YYYY, h:mm:ss a') ? "--"
              id:input.get("id")
              label:input.get("label")
              statusText: GetStatusText(input.get("userStatus"))
              new:true
            )
            setTimeout(()->
              newItem.unset("new")
            )
            newItem
        ,
          (item)->
            item.get("userStatus")? && item.get("userStatus") isnt Constants.PLAYING_STATE
        )

      @get("challenges").onSourceUpdated()
      @get("tab")?.on("change:active", (model)=>
        if !model.get("active") then @selectChallenge()
      )
      @on("change:selectedChallengeId", ()=>
        challengePlayers = @get("challengePlayerList")
        if @get("selectedChallenge")?.get("users")?
          challengePlayers.stopListening(@get("selectedChallenge").get("users"))
        challengePlayers.unwatch(true)
        if @get("selectedChallengeId")?
          @set("selectedChallenge",AppState.loadGame(@get("selectedChallengeId")))
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

    selectChallenge:(id)->
      for challenge in @get("challenges").models
        if challenge.get("id") is id
          @set("selectedChallengeId", id)
          challenge.set("selected", true)
        else
          challenge.unset("selected")
      if @get("selectedChallengeId") isnt id then @unset("selectedChallengeId")

    issueChallenge:(id)->
      if (!id?) then throw new Error("Cannot send challenge, user identifier missing.")
      AppState.issueChallenge(id, @get("selectedChallenge"))

    acceptChallenge:()->
      AppState.acceptChallenge(@get("selectedChallenge"))
  )


  ReviewChallengesViewModel
)

