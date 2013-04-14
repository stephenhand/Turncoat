define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, GameStateModel, StateRegistry)->
  class ManOWarGameState extends GameStateModel
    players:new Backbone.Collection(
      model:Player
    )
  StateRegistry.registerType("ManOWarGameState", ManOWarGameState)
  ManOWarGameState
)

