define(['underscore', 'backbone'], (_, Backbone)->
  GameStateModel = Backbone.Model.extend(

    toJSON:()->
      throw new Error("Not implemented")

    fromString:(input)->
      throw new Error("Not implemented")
  )


  GameStateModel
)