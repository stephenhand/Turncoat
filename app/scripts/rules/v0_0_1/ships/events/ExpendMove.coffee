define(["underscore", "lib/logging/LoggerFactory", "backbone", "lib/turncoat/RuleBookEntry"], (_, LoggerFactory, Backbone, RuleBookEntry)->

  log = LoggerFactory.getLogger()

  class ExpendMove extends RuleBookEntry

    getRules:(game)->
      super(game)
      apply:(event)->
        log.trace("MOVE EXPENDED")


      revert:()->
        throw new Error("Not implemented")

  new ExpendMove()
)
