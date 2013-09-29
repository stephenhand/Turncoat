

define(['underscore', 'backbone', 'moment', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry'], (_, Backbone, moment, GameStateModel, StateRegistry)->
  GameHeader = Backbone.Model.extend()
  GameHeader.toString=()->
    "GameHeader"

  StateRegistry.registerType("GameHeader", (unvivified)->
    vivified = GameStateModel.vivifier(unvivified, GameHeader)
    vivified.set("created", moment.utc(unvivified.created))
    vivified.set("lastActivity", moment.utc(unvivified.lastActivity))
  )

  GameHeader
)

