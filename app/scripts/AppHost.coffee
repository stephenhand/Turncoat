define(['backbone','rivets', 'jqModal', 'AppState', 'lib/turncoat/Factory', 'UI/ManOWarTableTopView', 'text!data/config.txt'], (Backbone, rivets, modal, AppState, Factory, ManOWarTableTopView, configText)->
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
        ":gameIdentifier":"launch"
    )

    launch:(gameIdentifier)=>

      if (gameIdentifier?)
        AppState.createGame()
      AppHost.render()
      if (!gameIdentifier?)
        AppState.trigger("gameDataRequired")

    render:()->
      @rootView = new ManOWarTableTopView(gameState:AppState.game?.state)
      @rootView.render()

    initialise:()->
      configureRivets()
      @router.on("route:launch", (gameIdentifier)->
        @launch(gameIdentifier)
      ,@)
      try
        Backbone.history.start()
      catch error

  config = JSON.parse(configText)
  Factory.setDefaultMarshaller(config.defaultMarshaller)

  AppHost

)