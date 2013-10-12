PLAYING_USERSTATUS = "PLAYING"

define(["setTimeout", "underscore", "backbone", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "AppState"], (setTimeout, _, Backbone, ObservingViewModelCollection, ObservableOrderCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when "READY"
        "Waiting on other players to respond to the challenge."
      when "CHALLENGED"
        "A challenge awaiting your response."

  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new ObservingViewModelCollection())
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
        if @get("selectedChallengeId")?
          @set("selectedChallenge",AppState.loadGame(@get("selectedChallengeId")))
          if @get("selectedChallenge")?
            @set("challengePlayerList", new Backbone.Collection(

              for player in @get("selectedChallenge").get("players").models
                new Backbone.Model(
                  id:player.get("id")
                  name:player.get("name")
                  user:player.get("user")
                  description:player.get("description")

                )
            ))
          @get("challengePlayerList")?.find((p)->p.get("user")?.get("id") is AppState.get("currentUser").get("id"))?.set("selectedForUser",true)
        else
          @unset("selectedChallenge")
          @unset("challengePlayerList")
      )

    selectChallenge:(id)->
      for challenge in @get("challenges").models
        if challenge.get("id") is id
          @set("selectedChallengeId", id)
          challenge.set("selected", true)
        else
          challenge.unset("selected")
      if @get("selectedChallengeId") isnt id then @unset("selectedChallengeId")
  )


  ReviewChallengesViewModel
)

