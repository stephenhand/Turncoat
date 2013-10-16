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
      if !name then throw new Error("Sub route name required")

      current = new Route(Backbone.history.getFragment())
      if route && !current.subRoutes? then current.subRoutes = {}
      if (current.subRoutes && current.subRoutes[name]) || route

        if route then current.subRoutes[name] = new Route(route) else delete current.subRoutes[name]
        globalRouter.navigate(current.toString())


    unsetSubRoute:@setSubRoute

  _.extend(Router, Backbone.Events)
  globalRouter.on("route:navigate", (path)->
    Router.trigger("navigate", new Route(path))
  )



  Router
)

