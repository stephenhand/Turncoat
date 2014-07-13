define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/ships/Actions", "rules/v0_0_1/ships/AssetPermittedActions"], (_, Backbone,
RuleBookEntry,
Actions,
AssetPermittedActions)->

  new RuleBookEntry(
    actions:Actions
    "permitted-actions":AssetPermittedActions
  )
)

