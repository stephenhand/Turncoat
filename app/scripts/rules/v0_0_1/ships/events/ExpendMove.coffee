define(["underscore", "backbone", "lib/turncoat/RuleBookEntry"], (_, Backbone, RuleBookEntry)->
  class ExpendMove extends RuleBookEntry

    getRules:(game)->
      super(game)
      apply:()->

      revert:()->
        throw new Error("Not implemented")

  new ExpendMove()
)
