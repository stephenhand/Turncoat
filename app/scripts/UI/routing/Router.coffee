define(["underscore", "backbone", "UI/routing/Route"], (_, Backbone, Route)->
  globalRouter = new Backbone.Router(
    routes:
      "":"navigate"
      ":user":"navigate"
      ":user/:gameIdentifier":"launch"
      ":user/:gameIdentifier/:inner":"innerRoute"
      ":user?:inner":"innerRouteNoUser"
  )

  Router =
    activate:()->
      Backbone.history.start()
    setSubRoute:(name, route)->
      current = new Route(Backbone.history.getFragment())
      if !current.subRoutes? then current.subRoutes = {}
      current.subRoutes[name] = new Route(route)
      globalRouter.navigate(current.toString())


    unsetSubRoute:(name)->

  _.extend(Router, Backbone.Events)
  globalRouter.on("route:navigate", (path)->
    Router.trigger("navigate", new Route(path))
  )



  Router
)

