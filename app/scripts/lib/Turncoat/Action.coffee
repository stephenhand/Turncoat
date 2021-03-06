define(['underscore','backbone'], (_,Backbone)->
  Action = Backbone.Model.extend(
    initialize:(m, options)->
      @set("events", @get("events") ? new Backbone.Collection())
    reset:()->
      @get("events").reset()

    preview:(game)->
      throw new Error("Not implemented")

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