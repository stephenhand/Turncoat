define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry'], (_, Backbone, GameStateModel, TypeRegistry)->
  class AssetPosition extends GameStateModel
    x : null
    y : null
    bearing : null
  AssetPosition.toString=()->
      "AssetPosition"

  TypeRegistry.registerType("AssetPosition", AssetPosition)

  AssetPosition
)