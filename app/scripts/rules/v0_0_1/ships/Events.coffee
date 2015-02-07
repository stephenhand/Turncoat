define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/ships/events/ChangePosition", "rules/v0_0_1/ships/events/ExpendMove"], (_, Backbone, RuleBookEntry, ChangePosition, ExpendMove)->
  new RuleBookEntry(
    changePosition:ChangePosition
    expendMove:ExpendMove
  )
)
