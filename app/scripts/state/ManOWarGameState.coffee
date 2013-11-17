define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/Player'], (_, Backbone, GameStateModel, StateRegistry, Player)->
  class ManOWarGameState extends GameStateModel
    players:new Backbone.Collection(
      model:Player
    )
  ManOWarGameState.toString=()->
      "ManOWarGameState"
  StateRegistry.registerType("ManOWarGameState",ManOWarGameState)

  ManOWarGameState
)

