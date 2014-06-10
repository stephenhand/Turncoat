define(['underscore', 'backbone', 'UI/widgets/GameBoardViewModel', ], (_, Backbone, GameBoardViewModel)->
  PlayAreaViewModel = Backbone.Model.extend(
    initialize: (m, options)->
      @set("gameBoard", new GameBoardViewModel())


    setGame:(game)->
      @get("gameBoard").setGame(game)

      if (game?)
        @activateOverlay=(id, layer)->
          @get("gameBoard").get(layer).add(new Backbone.Model(id:id))
          @trigger("overlayRequest",
            id:id
            layer:layer
            gameData:game
          )


      else
        @activateOverlay=()->

    activateOverlay:()->
  )

  PlayAreaViewModel
)

