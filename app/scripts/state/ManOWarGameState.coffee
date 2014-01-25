define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, GameStateModel, StateRegistry, Player)->
  class ManOWarGameState extends Game
    players:new Backbone.Collection(
      model:Player
    )
  ManOWarGameState.toString=()->
    "ManOWarGameState"
  StateRegistry.registerType("ManOWarGameState",ManOWarGameState)

  ManOWarGameState
)

