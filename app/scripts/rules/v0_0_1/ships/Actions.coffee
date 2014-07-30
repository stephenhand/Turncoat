define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/ships/actions/Move"], (_, Backbone, RuleBookEntry, Move)->

  new RuleBookEntry(
    move:Move
  )
)

