define(["underscore", "backbone"], (_, Backbone)->
  Adapter =
    subscribe:(obj,keypath,callback)->
      keypath?=[]
      if !_.isArray(keypath) then keypath=keypath.split(".")
      if (keypath[1])
        key = keypath.shift()
        val = obj.get(key)
        if !val? && keypath.length>0
          return
        @subscribe(val ,keypath, callback)
      else
        obj._subscribeCallback = callback
        obj.on("change:" + keypath[0], callback)
        if obj.get(keypath[0])? && obj.get(keypath[0]) instanceof Backbone.Collection
          obj.get(keypath[0]).on("add", callback)
          obj.get(keypath[0]).on("remove", callback)
          obj.get(keypath[0]).on("reset", callback)

    unsubscribe:(obj,keypath,callback)->
      keypath?=[]
      if !_.isArray(keypath) then keypath=keypath.split(".")
      if (keypath[1])
        key = keypath.shift()
        val = obj.get(key)
        if !val? && keypath.length>0
          return
        @unsubscribe(val ,keypath, callback)
      else
        obj._subscribeCallback = undefined
        obj.off("change:" + keypath[0], callback)
        obj.get(keypath[0])?.off?("add", callback)
        obj.get(keypath[0])?.off?("remove", callback)
        obj.get(keypath[0])?.off?("reset", callback)

    read:(obj,keypath)->
      keypath?=[]
      if !_.isArray(keypath) then keypath=keypath.split(".")
      if (keypath[0])
        key = keypath.shift()
        val = null
        switch key
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
            val = obj.get(key)
        if !val?
          val
        else
          @read(val ,keypath)
      else
        if (obj instanceof Backbone.Collection)
          return obj["models"]
        else
          obj

    publish: (obj, keypath, value)->
      keypath ?= []
      if !_.isArray(keypath) then keypath=keypath.split(".")
      if (keypath[1])
        key = keypath.shift()
        val = obj.get(key)
        if !val? && keypath.length>0
          val=new Backbone.Model()
          obj.set(key, val)
          if (obj._subscribeCallback)
            @subscribe(val, key,

              obj._subscribeCallback)
        @publish(val ,keypath, value)
      else
        obj.set(keypath[0],value)


  Adapter
)

