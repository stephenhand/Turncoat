define(["backbone","rivets", "jqModal", "UI/rivets/Adapter", "AppState", "UI/ManOWarTableTopView"], (Backbone, rivets, modal, adapter, AppState , ManOWarTableTopView)->
  configureRivets = ()->
    rivets.configure(
      prefix:"rv"
      adapter:adapter

    )

  AppHost =
    router:new Backbone.Router(
      routes:
        "":"launch"
        ":user":"launch"
        ":user/:gameIdentifier":"launch"
        ":user/:gameIdentifier/:inner":"innerRoute"
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
      AppState.activate()

    innerRoute:(user, gameIdentifier, inner)->
      

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