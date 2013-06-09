define(["underscore", "backbone", 'lib/turncoat/GameStateModel'], (_, Backbone, GameStateModel)->
  Game=Backbone.Model.extend(
    initialize: (options)->

    loadState:(state)->
      if typeof state is "string"
        @state = GameStateModel.fromString(state)
      else
        @state = state
  )

  Game
)


