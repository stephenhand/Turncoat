define(["underscore", "backbone", "lib/turncoat/Constants", "UI/widgets/GameListViewModel", "UI/widgets/PlayerListViewModel", "AppState"], (_, Backbone, Constants, GameListViewModel, PlayerListViewModel, AppState)->
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
      @get("games").on("selectedGameChanged", (id)=>
        if id?
          @set("selectedGame",AppState.loadGame(id))
          if @get("selectedGame")?
            @get("playerList").unwatch()
            @get("playerList").watch(@get("selectedGame"))

        else
          @unset("selectedGame")
          @get("playerList").unwatch()
      )

    selectGame:(gameId)->
      @get("games").selectGame(gameId)
  )
  CurrentGamesViewModel
)

