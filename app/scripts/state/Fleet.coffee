define(['underscore', 'backbone','lib/state/FleetAsset'], (_, Backbone, FleetAsset)->
  Fleet = Backbone.Collection.extend(
    model:FleetAsset
  )


  Fleet
)