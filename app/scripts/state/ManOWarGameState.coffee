define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/Player'], (_, Backbone, GameStateModel, StateRegistry, Player)->
  class ManOWarGameState extends GameStateModel
    players:new Backbone.Collection(
      model:Player
    )
  StateRegistry.registerType("ManOWarGameState", (unvivified)->
    GameStateModel.vivify(unvivified, ManOWarGameState)
  )

  ManOWarGameState
)

