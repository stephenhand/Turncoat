

define(["underscore", "backbone", "lib/turncoat/Constants", "lib/turncoat/Game", "lib/turncoat/User", "UI/component/ObservingViewModelItem", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "UI/widgets/GameListViewModel", "UI/widgets/PlayerListViewModel", "AppState"], (_, Backbone, Constants, Game, User, ObservingViewModelItem, ObservingViewModelCollection, ObservableOrderCollection, GameListViewModel, PlayerListViewModel, AppState)->


  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("challenges", new GameListViewModel(null,
        filter:(item)->
          item.get("userStatus")? && item.get("userStatus") isnt Constants.PLAYING_STATE
      ))
      @set("challengePlayerList", new PlayerListViewModel())
      @listenTo(@get("challengePlayerList"), "currentUserStatusUpdate", (val)=>@set("selectedChallengeUserStatus", val))
      @get("tab")?.on("change:active", (model)=>
        if !model.get("active") then @get("challenges").selectGame()
      )
      @get("challenges").on("selectedChallengeChanged", (id)=>
        if id?
          @set("selectedChallenge",AppState.loadGame(id))
          if @get("selectedChallenge")?
            @get("challengePlayerList").unwatch()
            @get("challengePlayerList").watch(@get("selectedChallenge"))

        else
          @unset("selectedChallenge")
          @get("challengePlayerList").unwatch()
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

