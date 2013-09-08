PLAYING_USERSTATUS = "PLAYING"

define(['underscore', 'backbone', 'UI/BaseViewModelCollection', 'AppState'], (_, Backbone, BaseViewModelCollection, AppState)->
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
            input
        ,
          (item)->
            item.get("userStatus")? && item.get("userStatus") isnt PLAYING_USERSTATUS
        )
  )


  ReviewChallengesViewModel
)

