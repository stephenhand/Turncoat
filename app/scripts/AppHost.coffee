define(['backbone','rivets', 'jqModal', 'AppState', 'UI/ManOWarTableTopView'], (Backbone, rivets, modal, AppState , ManOWarTableTopView)->
  configureRivets = ()->
    rivets.configure(
      prefix:"rv"
      adapter:
        subscribe:(obj,keypath,callback)->
          obj.on('change:' + keypath, callback)
        unsubscribe:(obj,keypath,callback)->
          obj.off('change:' + keypath, callback)
        read:(obj,keypath)->
          keypath?=[]
          if !_.isArray(keypath) then keypath=keypath.split('.')
          if (keypath[0])
            val = obj.get(keypath.shift())
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
            val = obj.get(keypath.shift())
            @publish(val ,keypath)
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