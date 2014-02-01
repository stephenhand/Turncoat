define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/Game', 'lib/turncoat/StateRegistry'], (_, Backbone, GameStateModel, Game, StateRegistry, Player)->
  class ManOWarGameState extends Game
    players:new Backbone.Collection(
      model:Player
    )
  ManOWarGameState.toString=()->
    "ManOWarGameState"
  StateRegistry.registerType("ManOWarGameState",ManOWarGameState)

  ManOWarGameState
)

