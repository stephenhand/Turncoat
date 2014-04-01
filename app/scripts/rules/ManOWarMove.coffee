define(["underscore", "backbone", "lib/turncoat/Move"], (_, Backbone, Move)->
  class MOWMove extends Move

    getEndControllingPlayerId:(nextPlayerSelector)->
      @get("actions").last().get("playerId")





  MOWMove
)

