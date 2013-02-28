define(['underscore', 'backbone','lib/state/FleetAsset','StateRegistry'], (_, Backbone, FleetAsset, StateRegistry)->
  Fleet = Backbone.Collection.extend(
    model:FleetAsset
  )

  StateRegistry.registerType("Fleet", Fleet)
  Fleet
)