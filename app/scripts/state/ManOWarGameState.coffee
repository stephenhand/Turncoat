define(['underscore', 'backbone'], (_, Backbone)->
  class ManOWarGameState extends ManOWarStateObject
    Players:new Backbone.Collection(
      model:Player
    )

  ManOWarGameState
)

