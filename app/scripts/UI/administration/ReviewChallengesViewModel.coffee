PLAYING_USERSTATUS = "PLAYING"

define(['underscore', 'backbone', 'UI/BaseViewModelCollection', 'AppState'], (_, Backbone, BaseViewModelCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when "READY"
        "Waiting on other players to respond to the challenge."
      when "CHALLENGED"
        "A challenge awaiting your response."

  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new BaseViewModelCollection())
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
      @on()

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

