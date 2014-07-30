define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "lib/turncoat/Action"], (_, Backbone, RuleBookEntry, action)->

  move = new RuleBookEntry()
  move.getRule = ()->
    preview:(newProposedAction, game, asset, currentPreviewActions)->
      return new Action();

)