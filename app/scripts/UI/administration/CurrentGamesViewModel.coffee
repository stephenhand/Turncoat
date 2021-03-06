define(["underscore", "backbone","sprintf", "lib/turncoat/Constants","UI/routing/Route","UI/routing/Router", "UI/widgets/GameListViewModel", "UI/widgets/PlayerListViewModel", "AppState"], (_, Backbone, sprintf, Constants, Route, Router, GameListViewModel, PlayerListViewModel, AppState)->
  CurrentGamesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("games", new GameListViewModel(undefined,
        filter:(item)->
          item.get("userStatus")? && item.get("userStatus") is Constants.PLAYING_STATE))
      @set("playerList", new PlayerListViewModel())
      @listenTo(@get("playerList"), "currentUserStatusUpdate", (val)=>@set("selectedGameUserStatus", val))
      @get("tab")?.on("change:active", (model)=>
        if !model.get("active") then @get("games").selectGame()
      )

      @get("games").on("selectedGameChanged", (id)->
        if @get("selectedGame") then @stopListening(@get("selectedGame"),"movesUpdated")
        if id?
          @set("selectedGame",AppState.loadGame(id))
          if @get("selectedGame")?
            @get("playerList").unwatch()
            isCurrentUserControlling = ()=>
              @set("isCurrentUserControlling",AppState.get("currentUser").get("id") is @get("selectedGame").getCurrentControllingUser().get("id"))

            @listenTo(@get("selectedGame"),"movesUpdated",isCurrentUserControlling)
            isCurrentUserControlling()
            @get("playerList").watch(@get("selectedGame"))
        else
          @unset("selectedGame")
          @get("playerList").unwatch()
      ,@)

    selectGame:(gameId)->
      @get("games").selectGame(gameId)

    launchGame:()->
      Router.setRoute(new Route(sprintf("/%s/%s",AppState.get("currentUser").get("id"), @get("selectedGame").get("id"))))

  )
  CurrentGamesViewModel
)

