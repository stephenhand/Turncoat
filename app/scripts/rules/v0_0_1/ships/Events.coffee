define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/ships/events/ChangePosition"], (_, Backbone, RuleBookEntry, ChangePosition)->
  new RuleBookEntry(
    changePosition:ChangePosition
  )
)
