define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/ships/Actions", "rules/v0_0_1/ships/Events", "rules/v0_0_1/ships/AssetPermittedActions"], (_, Backbone,
RuleBookEntry,
Actions,
Events,
AssetPermittedActions)->

  new RuleBookEntry(
    actions:Actions
    events:Events
    "permitted-actions":AssetPermittedActions
  )
)

