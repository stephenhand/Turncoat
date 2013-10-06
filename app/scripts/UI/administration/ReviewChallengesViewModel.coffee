PLAYING_USERSTATUS = "PLAYING"

define(['underscore', 'backbone', 'UI/component/ObservingViewModelCollection', 'AppState'], (_, Backbone, ObservingViewModelCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when "READY"
        "Waiting on other players to respond to the challenge."
      when "CHALLENGED"
        "A challenge awaiting your response."

  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new ObservingViewModelCollection())
      @get("challenges").watch([AppState.get("games")])

      @get("challenges").onSourceUpdated=()->
        @updateFromWatchedCollections(
          (item, watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
        ,
          (input)->
            new Backbone.Model(
              created:input.get("created")?.format?('MMMM Do YYYY, h:mm:ss a') ? "--"
              id:input.get("id")
              label:input.get("label")
              statusText: GetStatusText(input.get("userStatus"))
            )
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
                  label:player.get("label")
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

