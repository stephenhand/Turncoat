PLAYING_USERSTATUS = "PLAYING"

define(["setTimeout", "underscore", "backbone", "UI/component/ObservingViewModelItem", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "AppState"], (setTimeout, _, Backbone, ObservingViewModelItem, ObservingViewModelCollection, ObservableOrderCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when "READY"
        "Waiting on other players to respond to the challenge."
      when "CHALLENGED"
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

      @get("challenges").watch([AppState.get("games")])

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
            item.get("userStatus")? && item.get("userStatus") isnt PLAYING_USERSTATUS
        )

      @get("challenges").onSourceUpdated()
      @get("tab")?.on("change:active", (model)=>
        if !model.get("active") then @selectChallenge()
      )
      @on("change:selectedChallengeId", ()=>
        challengePlayers = @get("challengePlayerList")
        challengePlayers.unwatch(true)
        if @get("selectedChallengeId")?
          @set("selectedChallenge",AppState.loadGame(@get("selectedChallengeId")))
          if @get("selectedChallenge")?
            challengePlayers.watch([@get("selectedChallenge").get("players")])
            rcvm = @
            challengePlayers.onSourceUpdated=()->
              @updateFromWatchedCollections(
                (item, watched)->
                  item.get("id")? and item.get("id") is watched.get("id")
              ,
                (input)->
                  if input.get("user")? and !(input.get("user") instanceof Backbone.Model) then throw new Error("Invalid user")
                  user = input.get("user") ? get:()->
                  ovmi=new ObservingViewModelItem(
                    id:input.get("id")
                    name:input.get("name")
                    user:new Backbone.Model(
                      id:user.get("id")
                      status:user.get("status")
                    )
                    description:input.get("description")
                  )
                  watchedUser = input.get("user")
                  ovmi.watch([
                      model:input
                      attributes:[
                        "name",
                        "description"
                      ]
                    ,
                      model:watchedUser
                      attributes:[
                        "status"
                      ]
                    ]
                  ,
                    (model, attribute)->
                      if model is input
                        if attribute is "user"
                          ovmi.get("user").set(
                            id:model.get("user").get("id")
                            status:model.get("user").get("status")
                          )
                          ovmi.unwatch(watchedUser)
                          watchedUser = model.get("user")
                          ovmi.watch(
                            [
                              model:watchedUser
                              attributes:[
                                "status"
                              ]
                            ]
                          ,
                            ovmi.onModelUpdated
                          )
                        else
                          ovmi.set(
                            name:model.get("name")
                            description:model.get("description")
                          )
                      else if input.get("user")? and model is input.get("user")
                        ovmi.get("user").set(
                          id:model.get("id")
                          status:model.get("status")
                        )
                  )
                  ovmi
              ,
                undefined
              ,
                (removed)->
                  removed.unwatch()
              )
              currentPlayer = challengePlayers?.find((p)->p.get("user")?.get("id") is AppState.get("currentUser").get("id"))
              if currentPlayer?
                currentPlayer.set("selectedForUser",true)
                rcvm.set("selectedChallengeUserStatus", currentPlayer.get("user").get("status"))
              else
                rcvm.unset("selectedChallengeUserStatus")
            challengePlayers.onSourceUpdated()
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
  )


  ReviewChallengesViewModel
)

