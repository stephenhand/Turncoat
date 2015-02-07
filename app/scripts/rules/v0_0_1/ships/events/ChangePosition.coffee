define(["underscore", "backbone", "lib/turncoat/RuleBookEntry"], (_, Backbone, RuleBookEntry)->
  class ChangePosition extends RuleBookEntry

    getRules:(game)->
      super(game)
      apply:()->

      revert:()->

  new ChangePosition()
)

