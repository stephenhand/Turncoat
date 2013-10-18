define(["backbone","rivets", "jqModal", "UI/rivets/Adapter", "UI/routing/Route", "UI/routing/Router", "AppState", "UI/ManOWarTableTopView"], (Backbone, rivets, modal, Adapter, Route, Router, AppState , ManOWarTableTopView)->
  configureRivets = ()->
    rivets.configure(
      prefix:"rv"
      adapter:Adapter

    )

  AppHost =


    launch:()=>
      AppHost.render()
      AppState.activate()

    innerRoute:(user, gameIdentifier, inner)->
      if (user is AppState.get("currentUser")?.id) && ((gameIdentifier is "-" && !AppState.get("game")?)|| gameIdentifier is AppState.get("game")?.id)
        @rootView.routeChanged(new Route(inner))
      else
        @launch(user, gameIdentifier)

    render:()->
      @rootView = new ManOWarTableTopView(gameState:AppState.get("game")?.state)
      @rootView.render()

    initialise:()->
      configureRivets()

      Router.on("navigate", (route)=>
        user = route?.parts?[0]
        gameIdentifier = route?.parts?[1]
        if (user?)
          AppState.loadUser(user)
        if (gameIdentifier?)
          AppState.createGame()
        if !@rootView? then @launch()
        if (!user? && !gameIdentifier?)
          AppState.trigger("userDataRequired")
        else if (!gameIdentifier? && !(route?.subRoutes?.administrationDialogue?))
          AppState.trigger("gameDataRequired")
        else
          @rootView.routeChanged(route)

      ,@)
      AppState.on("gameDataRequired", ()=>
        if !Router.getSubRoute("administrationDialogue")? then Router.setSubRoute("administrationDialogue", "default")
      )
      try
        Router.activate()
      catch error

  AppHost

)