define(['underscore', 'backbone', 'lib/StateRegistry'], (_, Backbone, StateRegistry)->
  Player = Backbone.Model.extend(

  )

  StateRegistry.registerType("Player", Player)

  Player
)