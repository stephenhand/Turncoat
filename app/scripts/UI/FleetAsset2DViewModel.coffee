define(["underscore", "lib/logging/LoggerFactory", "backbone", "crypto", "lib/2D/TransformBearings", "UI/component/ObservingViewModelItem"], (_, LoggerFactory, Backbone, Crypto, TransformBearings, ObservingViewModelItem)->
  log = LoggerFactory.getLogger()

  class FleetAsset2DViewModel extends ObservingViewModelItem
    initialize:(m, options)->
      super(m, options)
      if (options?.model?)
        @watch([
          model:options.model
          attributes:[
            "position"
          ]
        ,
          model:options.model.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        ])
        @set("modelId", options.model.id)
        @set("UUID", Crypto.MD5(options.model.id))
        @set("classList", @get("classList")+" fleet-asset-2d")
        dim = options.model.get("dimensions")
        @set("length", dim.get("length"))
        @set("width", dim.get("width"))
        @updateFromFleetAsset(options.model)


    updateFromFleetAsset:(model)->
      pos = model.get("position")
      @set("xpx",pos.get("x"))
      @set("ypx",pos.get("y"))
      @set("transformDegrees",pos.get("bearing"))
      @calculateClosestMoveAction=(moveType, x, y, margin, onComplete)->
        margin ?=0
        moveDefinition = model.get("actions").findWhere(name:"move").get("types").findWhere(name:moveType)

        maneuvers = moveDefinition.get("maneuvers")
        ghostGame = model.getRoot().ghost()
        ghostModel = ghostGame.searchGameStateModels((m)->m.get("id") is model.get("id"))[0]
        if (!ghostModel?) then throw new Error("Model not found in ghosted game, the ghosted game is inconsistent")
        rules = ghostGame.getRuleBook().lookUp("ships.actions.move").getActionRules(ghostGame)
        ghostGame.activate("CASPER", transportKey:"DummyTransport")
        acts = []
        runMove = ()->
          ghostPos = ghostModel.get("position")
          minBearing = TransformBearings.rotateBearing(ghostPos.get("bearing"), moveDefinition.get("minDirection") ? 0)
          maxBearing = TransformBearings.rotateBearing(ghostPos.get("bearing"), moveDefinition.get("maxDirection") ? 0)
          targetBD = TransformBearings.vectorToBearingAndDistance(
            x:x-ghostPos.get("x")
            y:y-ghostPos.get("y")
          )
          log.debug("targetBD.bearing: "+targetBD.bearing+"\r\nminBearing: "+minBearing+ "\r\nmaxBearing: "+maxBearing)
          if (TransformBearings.rotationBetweenBearings(targetBD.bearing, minBearing) < margin) and (TransformBearings.rotationBetweenBearings(maxBearing, targetBD.bearing) < margin)
            act = rules.calculateStraightLineMoveRequired(ghostModel, moveType, x, y)
          else
            act = rules.calculateManeuverRequired(ghostModel, moveType, maneuvers.at(0), x, y)?.action
          if act?
            rules.resolveAction(act, false)
            acts.push(act)
          else
            onComplete(acts)
            ghostModel.off(runMove)

        ghostModel.get("position").on("change:x change:y change:bearing", runMove)
        runMove()






    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset(model)


  FleetAsset2DViewModel
)

