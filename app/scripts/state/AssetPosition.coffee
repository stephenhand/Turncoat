define(['underscore', 'backbone', 'StateRegistry'], (_, Backbone, StateRegistry)->
  class AssetPosition extends ManOWarStateObject


  StateRegistry.registerType("AssetPosition", AssetPosition)
  AssetPosition
)