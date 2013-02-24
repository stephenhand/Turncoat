define(['underscore', 'backbone','State'], (_, Backbone, State)->
  class ManOWarState extends State
    toString:()->
      JSON.stringify(this)

    fromString:(input)->
      _.extend(@,JSON.parse(input))


  ManOWarState
)