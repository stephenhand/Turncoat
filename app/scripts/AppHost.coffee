define(['backbone','rivets', 'jqModal', 'AppState', 'UI/ManOWarTableTopView'], (Backbone, rivets, modal, AppState , ManOWarTableTopView)->
  configureRivets=()->
    rivets.configure(
      prefix:"rv"
      adapter:
        subscribe:(obj,keypath,callback)->
          obj.on('change:' + keypath, callback)
        unsubscribe:(obj,keypath,callback)->
          obj.off('change:' + keypath, callback)
        read:(obj,keypath)->
          if (obj instanceof Backbone.Collection) then obj["models"] else obj.get(keypath)
        publish: (obj, keypath, value)->
          obj.set(keypath, value)
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