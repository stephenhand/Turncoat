define(['underscore', 'backbone', 'crypto', 'lib/2D/TransformBearings', 'UI/component/ObservingViewModelItem'], (_, Backbone, Crypto, TransformBearings, ObservingViewModelItem)->
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
      @calculateClosestMoveAction=(moveType, x, y, margin)->
        margin ?=0
        moveDefinition = model.get("actions").findWhere(name:"move").get("types").findWhere(name:moveType)
        minBearing = TransformBearings.rotateBearing(pos.get("bearing"), moveDefinition.get("minDirection") ? 0)
        maxBearing = TransformBearings.rotateBearing(pos.get("bearing"), moveDefinition.get("maxDirection") ? 0)
        targetBD = TransformBearings.vectorToBearingAndDistance(
          x:x-pos.get("x")
          y:y-pos.get("y")
        )
        maneuvers = moveDefinition.get("maneuvers")
        rules = model.getRoot().getRuleBook().lookUp("ships.actions.move").getActionRules(model.getRoot())
        console.log("targetBD.bearing: "+targetBD.bearing)
        console.log("minBearing: "+minBearing)
        console.log("maxBearing: "+maxBearing)
        if (TransformBearings.rotationBetweenBearings(targetBD.bearing, minBearing) < margin) and (TransformBearings.rotationBetweenBearings(maxBearing, targetBD.bearing) < margin)
          act = rules.calculateStraightLineMoveRequired(model, moveType, x, y)
        else
          act = rules.calculateManeuverRequired(model, moveType, maneuvers.at(0), x, y)?.action
        if act? then rules.resolveAction(act, false)
        act




    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset(model)


  FleetAsset2DViewModel
)

