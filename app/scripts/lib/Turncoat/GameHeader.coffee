

define(['underscore', 'backbone', 'moment', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, moment, GameStateModel, StateRegistry)->
  GameHeader = Backbone.Model.extend(
    initialize:()->
      if typeof(@get("created")) is "string" then @set("created", moment.utc(@get("created")))
      if typeof(@get("lastActivity")) is "string" then @set("lastActivity", moment.utc(@get("lastActivity")))
  )
  GameHeader.toString=()->
    "GameHeader"

  StateRegistry.registerType("GameHeader", GameHeader)

  GameHeader
)

