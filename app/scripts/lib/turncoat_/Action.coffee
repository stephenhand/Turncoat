define(['underscore','backbone'], (_,Backbone)->
  Action = Backbone.Model.extend(
    initialise:(m, options)->
      @set("events", @get("events") ? new Backbone.Collection())

    play:(parameters)->
      throw new Error("Not implemented")

    replay:(result)->
      throw new Error("Not implemented")

    rewind:(result)->
      throw new Error("Not implemented")

    toString:()->
      throw new Error("Not implemented")

    fromString:(input)->
      throw new Error("Not implemented")

  )

  Action
)