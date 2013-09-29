define(['uuid'], ( UUID)->
  class UniquelyIdentifiable
    makeInstancesUnique:(prototype)->
      tostr = prototype.toString
      prototype.toString =()->
        @toString.instanceUUID ?= UUID()+
        tostr()+" ["+@toString.instanceUUID+"]"

    constructor:()->
      hashVal = UUID()

      @__origToString = @toString()
      @toString=()->
        hashVal
)

