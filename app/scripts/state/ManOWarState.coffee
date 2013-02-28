define(['underscore', 'backbone', 'State', 'StateRegistry'], (_, Backbone, State, StateRegistry)->
  class ManOWarState extends State
    toString:()->
      JSON.stringify(this)

    fromString:(input)->
      _.extend(@,JSON.parse(input))



  StateRegistry.registerType("ManOWarState", ManOWarState)
  ManOWarState
)