define(['underscore', 'backbone', 'StateRegistry'], (_, Backbone, StateRegistry)->
  FleetAsset = Backbone.Model.extend(

  )

  StateRegistry.registerType("FleetAsset", FleetAsset)
  FleetAsset
)