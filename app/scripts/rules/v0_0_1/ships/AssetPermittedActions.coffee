define(["underscore", "backbone", "lib/turncoat/Action", "lib/turncoat/RuleBookEntry"], (_, Backbone, Action, RuleBookEntry)->
  AssetPermittedActions = new RuleBookEntry()
  AssetPermittedActions.getActionRules = ()->
    getPermittedActionsForAsset:(asset, game)->
      ret = []
      for action in asset.get("actions")?.models ? []
        if action.get("types")
          for actionType in action.get("types").models
            if !actionType.get("rule")? then throw Error("All actions require a rule to be specified")
            ret.push(new Action(base:action.get("name"),name:actionType.get("name"),rule:actionType.get("rule")))
        else
          if !action.get("rule")? then throw Error("All actions require a rule to be specified")
          ret.push(new Action(base:action.get("name"), name:action.get("name"),rule:action.get("rule")))
      ret.push(new Action(name:"finish",rule:"ships.actions.finish"))
      ret


  AssetPermittedActions
)

