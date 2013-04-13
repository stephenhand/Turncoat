define(['underscore', 'backbone', 'lib/turncoat/StateRegistry','state/FleetAsset'], (_, Backbone, StateRegistry, FleetAsset)->
  class Player extends ManOWarStateObject
    Fleet:new Backbone.Collection.extend(
      model:FleetAsset
    )


  StateRegistry.registerType("Player", Player)

  Player
)