define(['underscore', 'backbone', 'moment', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry'], (_, Backbone, moment, GameStateModel, TypeRegistry)->
  LogEntry = Backbone.Model.extend(
    initialize:()->
      if typeof(@get("timestamp")) is "string" then @set("timestamp", moment.utc(@get("timestamp")))

  )
  LogEntry.toString=()->
    "LogEntry"

  TypeRegistry.registerType("LogEntry", LogEntry)
  LogEntry
)

