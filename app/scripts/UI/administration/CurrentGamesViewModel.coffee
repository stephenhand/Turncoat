define(["underscore", "backbone", "lib/turncoat/Constants", "UI/widgets/GameListViewModel", "UI/widgets/PlayerListViewModel"], (_, Backbone, Constants, GameListViewModel, PlayerListViewModel)->
  CurrentGamesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("games", new GameListViewModel(undefined,
        filter:(item)->
          item.get("userStatus")? && item.get("userStatus") is Constants.PLAYING_STATE))
      @set("playerList", new PlayerListViewModel())

    selectGame:(gameId)->
      @get("games").selectGame(gameId)
  )
  CurrentGamesViewModel
)

