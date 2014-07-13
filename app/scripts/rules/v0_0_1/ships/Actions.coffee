define(["underscore", "backbone", "lib/turncoat/RuleBookEntry"], (_, Backbone, RuleBookEntry)->

  new RuleBookEntry(
    actions:Actions
    "permitted-actions":AssetPermittedActions
  )
)

