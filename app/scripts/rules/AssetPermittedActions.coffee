define(["underscore", "backbone"], (_, Backbone)->
  AssetPermittedActions
    getPermittedActionsForAsset:(asset, game)->
      ret = []
      for action in asset.get("actions").models
        if action.get("types")
          ret.push(actionType.get("name")) for actionType in action.get("types").models
        else
          ret.push(action.get("name"))
      ret.push("pass")
      ret


  AssetPermittedActions
)

