define(['underscore','backbone'], (_,Backbone)->
  Action = Backbone.Model.extend(
    run:(parameters)->
      throw new Error("Not implemented")

    replay:(result)->
      throw new Error("Not implemented")

    rollBack:(result)->
      throw new Error("Not implemented")

    toString:()->
      throw new Error("Not implemented")

    fromString:(input)->
      throw new Error("Not implemented")

  )

  Action
)