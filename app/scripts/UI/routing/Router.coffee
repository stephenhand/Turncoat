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
    openModal:(name, route)->

    closeModal:(name)->

  _.extend(Router, Backbone.Events)
  globalRouter.on("route:navigate", ()->
    Router.trigger()
  )



  Router
)

