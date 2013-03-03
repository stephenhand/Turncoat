define(['underscore', 'backbone'], (_, Backbone)->
  State = Backbone.Model.extend(

     toString:()->
       throw new Error("Not implemented")

     fromString:(input)->
       throw new Error("Not implemented")
  )


  State
)