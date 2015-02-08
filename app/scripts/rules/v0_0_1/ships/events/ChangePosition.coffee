define(["underscore", "backbone", "lib/2D/TransformBearings", "lib/turncoat/RuleBookEntry", "state/FleetAsset"], (_, Backbone, TransformBearings, RuleBookEntry, FleetAsset)->
  class ChangePosition extends RuleBookEntry

    getRules:(game)->
      super(game)
      apply:(event)->
        asset = FleetAsset.findByID(game, event.get("asset"))
        pos = asset.get("position")
        vector = event.get("vector")
        pos.set("x", pos.get("x")+(vector.get("x") ? 0))
        pos.set("y", pos.get("y")+(vector.get("y") ? 0))
        pos.set("bearing", TransformBearings.rotateBearing(pos.get("bearing"),(vector.get("rotation") ? 0)))

      revert:()->
        throw new Error("Not implemented")

  new ChangePosition()
)

