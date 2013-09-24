define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, GameStateModel, StateRegistry)->
  class AssetPosition extends GameStateModel
    x : null
    y : null
    bearing : null

  StateRegistry.registerType("AssetPosition", (unvivified)->
    GameStateModel.vivifier(unvivified, AssetPosition)
  )

  AssetPosition
)