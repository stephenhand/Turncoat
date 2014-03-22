define(['underscore', 'backbone', 'UI/widgets/GameBoardViewModel', ], (_, Backbone, GameBoardViewModel)->
  PlayAreaViewModel = Backbone.Model.extend(
    initialize: ()->
      @set("gameBoard", new GameBoardViewModel())

    setGame:(game)->
      @get("gameBoard").setGame(game)


  )

  PlayAreaViewModel
)

