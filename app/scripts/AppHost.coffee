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
        ":player":"launch"
        ":player/:gameIdentifier":"launch"
    )

    launch:(player, gameIdentifier)=>
      if (player?)
        AppState.loadPlayer(player)
      if (gameIdentifier?)
        AppState.createGame()
      AppHost.render()

      if (!player? && !gameIdentifier?)
        AppState.trigger("playerDataRequired")
      else if (!gameIdentifier?)
        AppState.trigger("gameDataRequired")

    render:()->
      @rootView = new ManOWarTableTopView(gameState:AppState.game?.state)
      @rootView.render()

    initialise:()->
      configureRivets()
      @router.on("route:launch", (gameIdentifier, player)->
        @launch(gameIdentifier, player)
      ,@)
      try
        Backbone.history.start()
      catch error

  config = JSON.parse(configText)
  Factory.setDefaultMarshaller(config.defaultMarshaller)

  AppHost

)