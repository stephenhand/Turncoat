define(["underscore", "backbone", "lib/turncoat/Action"], (_, Backbone, Action)->
  AssetPermittedActions =
    getPermittedActionsForAsset:(asset, game)->
      ret = []
      for action in asset.get("actions")?.models ? []
        if action.get("types")
          ret.push(new Action(name:actionType.get("name"))) for actionType in action.get("types").models
        else
          ret.push(new Action(name:action.get("name")))
      ret.push(new Action(name:"finish"))
      ret


  AssetPermittedActions
)

