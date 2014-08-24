define(["underscore", "backbone"], (_, Backbone)->
  Adapter =
    subscribe:(obj,keypath,callback)->
      obj.on("change:" + keypath, callback)
      if obj.get(keypath) instanceof Backbone.Collection
        obj.get(keypath).on("add", callback)
        obj.get(keypath).on("remove", callback)
        obj.get(keypath).on("reset", callback)

    unsubscribe:(obj,keypath,callback)->
      obj.off("change:" + keypath, callback)
      obj.off?("add", callback)
      obj.off?("remove", callback)
      obj.off?("reset", callback)

    read:(obj,keypath)->
      val = null
      console.log(keypath)
      switch keypath
        when "_indexOf"
          if obj.collection? then val = obj.collection.indexOf(obj) else val = -1
        when "_length"
          if (obj instanceof Backbone.Collection)
            return obj.length
          else if obj.collection?
            return obj.collection.length
          else
            return 0
        else
          if obj[keypath]
            val = obj[keypath]
          else
            val = obj.get(keypath)
          if val instanceof Backbone.Collection
            return val.models
          else
            return val

    publish: (obj, keypath, value)->
        obj.set(keypath,value)


  Adapter
)

