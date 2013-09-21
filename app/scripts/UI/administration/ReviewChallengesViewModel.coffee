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
      @challenges=new BaseViewModelCollection()
      @challenges.watch([AppState.get("games")])

      @challenges.onSourceUpdated=()->
        @updateFromWatchedCollections(
          (item, watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
        ,
          (input)->
            new Backbone.Model(
              id:input.get("id")
              statusText: GetStatusText(input.get("userStatus"))
            )
        ,
          (item)->
            item.get("userStatus")? && item.get("userStatus") isnt PLAYING_USERSTATUS
        )

      @challenges.onSourceUpdated()
  )


  ReviewChallengesViewModel
)

