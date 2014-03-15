define(["underscore", "backbone", "lib/turncoat/Constants", "UI/widgets/GameListViewModel"], (_, Backbone, Constants, GameListViewModel)->
  CurrentGamesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("games", new GameListViewModel(undefined,
        filter:(item)->
          item.get("userStatus")? && item.get("userStatus") is Constants.PLAYING_STATE))

    selectGame:(gameId)->
      @get("games").selectGame(gameId)
  )
  CurrentGamesViewModel
)

