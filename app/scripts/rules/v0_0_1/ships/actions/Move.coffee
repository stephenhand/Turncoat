define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "lib/turncoat/Action"], (_, Backbone, RuleBookEntry, action)->

  move = new RuleBookEntry()
  move.getRule = ()->
    preview:(action, game, asset)->
      return new Action();

)