define(['underscore', 'backbone', 'StateRegistry'], (_, Backbone, StateRegistry)->
  class FleetAsset extends ManOWarStateObject
    Position : new AssetPosition()


  StateRegistry.registerType("FleetAsset", FleetAsset)
  FleetAsset
)