define(["underscore", "backbone"], (_, RuleBookEntry)->
  class RuleBookEntry
    constructor:(subEntries)->
      @subEntries = subEntries ? {}
    getDescription:()->
      throw new Error("RuleBook entries must implement getDescription")
    getRule:()->
      throw new Error("RuleBook entries must implement getRule")

    lookUp:(rulePath)->
      dotPos = rulePath.indexOf(".")
      if dotPos is -1
        @subEntries[rulePath]
      else
        @subEntries[rulePath.substr(0,dotPos)].lookUp(rulePath.substr(dotPos+1))

  RuleBookEntry
)

