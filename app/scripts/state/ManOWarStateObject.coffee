define(['underscore', 'backbone', 'State', 'StateRegistry'], (_, Backbone, State, StateRegistry)->
  class ManOWarStateObject extends State
    toString:()->
      JSON.stringify(this)

    fromString:(input)->
      _.extend(@,JSON.parse(input))



  StateRegistry.registerType("ManOWarState", ManOWarState)
  ManOWarState
)