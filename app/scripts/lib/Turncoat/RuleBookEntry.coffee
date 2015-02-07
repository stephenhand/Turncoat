define(["underscore", "backbone"], (_, RuleBookEntry)->
  class RuleBookEntry
    constructor:(subEntries)->
      @subEntries = subEntries ? {}
    getDescription:()->
      throw new Error("RuleBook entries must implement getDescription")
    getRules:(game)->
      if !game? then throw new Error('A game must be supplied to retrieve rules')

    lookUp:(rulePath)->
      dotPos = rulePath.indexOf(".")
      if dotPos is -1
        @subEntries[rulePath]
      else
        @subEntries[rulePath.substr(0,dotPos)].lookUp(rulePath.substr(dotPos+1))

  RuleBookEntry
)

