define(['underscore', 'backbone', 'lib/turncoat/StateRegistry'], (_, Backbone, StateRegistry)->
  Player = Backbone.Model.extend(

  )

  StateRegistry.registerType("Player", Player)

  Player
)