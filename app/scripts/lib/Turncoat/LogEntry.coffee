define(['underscore', 'backbone', 'moment', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, moment, GameStateModel, StateRegistry)->
  LogEntry = Backbone.Model.extend()



  StateRegistry.registerType("LogEntry", (unvivified)->
    vivified = GameStateModel.vivifier(unvivified, LogEntry)
    vivified.set("timestamp", moment.utc(unvivified.timestamp))
  )
  LogEntry
)

