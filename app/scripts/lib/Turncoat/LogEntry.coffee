define(['underscore', 'backbone', 'moment', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, moment, GameStateModel, StateRegistry)->
  LogEntry = Backbone.Model.extend(
    initialize:()->
      if typeof(@get("timestamp")) is "string" then @set("timestamp", moment.utc(@get("timestamp")))
  )
  LogEntry.toString=()->
    "LogEntry"

  StateRegistry.registerType("LogEntry", LogEntry)
  LogEntry
)

