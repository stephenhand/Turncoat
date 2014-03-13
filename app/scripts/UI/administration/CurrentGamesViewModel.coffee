define(["underscore", "backbone", "UI/widgets/GameListViewModel"], (_, Backbone, GameListViewModel)->
  CurrentGamesViewModel = Backbone.Model.extend(
    initialize:()->
      @set("games", new GameListViewModel())

    selectGame:(gameId)->
      @get("games").selectGame(gameId)
  )
  CurrentGamesViewModel
)

