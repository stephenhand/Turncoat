define(['backbone','rivets', 'jqModal', 'AppState', 'UI/ManOWarTableTopView'], (Backbone, rivets, modal, AppState , ManOWarTableTopView)->
  configureRivets = ()->
    rivets.configure(
      prefix:"rv"
      adapter:
        subscribe:(obj,keypath,callback)->
          keypath?=[]
          if !_.isArray(keypath) then keypath=keypath.split('.')
          if (keypath[1])
            key = keypath.shift()
            val = obj.get(key)
            if !val? && keypath.length>0
              return
            @subscribe(val ,keypath, callback)
          else
            obj._subscribeCallback = callback
            obj.on('change:' + keypath[0], callback)

        unsubscribe:(obj,keypath,callback)->
          keypath?=[]
          if !_.isArray(keypath) then keypath=keypath.split('.')
          if (keypath[1])
            key = keypath.shift()
            val = obj.get(key)
            if !val? && keypath.length>0
              return
            @unsubscribe(val ,keypath, callback)
          else
            obj._subscribeCallback = undefined
            obj.off('change:' + keypath[0], callback)

        read:(obj,keypath)->
          keypath?=[]
          if !_.isArray(keypath) then keypath=keypath.split('.')
          if (keypath[0])
            key = keypath.shift()
            val = obj.get(key)
            if !val?
              val
            else
              @read(val ,keypath)
          else
            if (obj instanceof Backbone.Collection)
              obj["models"]
            else
              obj

        publish: (obj, keypath, value)->
          keypath ?= []
          if !_.isArray(keypath) then keypath=keypath.split('.')
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
    )

  AppHost =
    router:new Backbone.Router(
      routes:
        "":"launch"
        ":user":"launch"
        ":user/:gameIdentifier":"launch"
    )

    launch:(user, gameIdentifier)=>
      if (user?)
        AppState.loadUser(user)
      if (gameIdentifier?)
        AppState.createGame()
      AppHost.render()

      if (!user? && !gameIdentifier?)
        AppState.trigger("userDataRequired")
      else if (!gameIdentifier?)
        AppState.trigger("gameDataRequired")

    render:()->
      @rootView = new ManOWarTableTopView(gameState:AppState.get("game")?.state)
      @rootView.render()

    initialise:()->
      configureRivets()
      @router.on("route:launch", (gameIdentifier, user)->
        @launch(gameIdentifier, user)
      ,@)
      try
        Backbone.history.start()
      catch error

  AppHost

)