define(["underscore", "backbone", "UI/routing/Route"], (_, Backbone, Route)->
  globalRouter = new Backbone.Router(
    routes:
      "":"navigate"
      ":user":"navigate"
  )

  Router =
    activate:()->
      Backbone.history.start()
    setSubRoute:(name, route, options)->
      if !name then throw new Error("Sub route name required")

      current = @getCurrentRoute()
      if route && !current.subRoutes? then current.subRoutes = {}
      if (current.subRoutes && current.subRoutes[name]) || route

        if route then current.subRoutes[name] = new Route(route) else delete current.subRoutes[name]
        globalRouter.navigate(current.toString(), _.extend(trigger:true, options))


    unsetSubRoute:(name)->
      @setSubRoute(name)

    getSubRoute:(name)->
      r = @getCurrentRoute()
      return r.subRoutes?[name]

    getCurrentRoute:()->
      new Route(Backbone.history.getFragment())

    setRoute:(route)->
      globalRouter.navigate(route.toString(),trigger:true)

  _.extend(Router, Backbone.Events)
  globalRouter.on("route:navigate", (path)->
    Router.trigger("navigate", new Route(path))
  )



  Router
)

