define(['underscore', 'backbone', 'StateRegistry'], (_, Backbone, StateRegistry)->
  AssetPosition = Backbone.Model.extend(

  )

  StateRegistry.registerType("AssetPosition", AssetPosition)
  AssetPosition
)