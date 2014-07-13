define(["underscore", "backbone", "lib/turncoat/RuleBookEntry", "rules/v0_0_1/Ships"], (_, Backbone,
  RuleBookEntry,
  Ships)->


  new RuleBookEntry(
    ships:Ships
  )
)

