mockBackboneRouter = {}
mockBackboneRouter.on = JsMockito.mockFunction()
mockRoute = {}
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("backbone", 'UI/routing/Router', (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Router:()->
        mockBackboneRouter
      history:{}

    )
  )
  Isolate.mapAsFactory("UI/routing/Route", 'UI/routing/Router', (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret.func = ()->
      ret
    )
  )
)
define(["isolate!UI/routing/Router"], (Router)->
  mocks=window.mockLibrary['UI/routing/Router']
  suite("Router", ()->
    setup(()->
      mocks["UI/routing/Route"].func = JsMockito.mockFunction()
      JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
        ret =
          builtWithPath:s
          on:JsMockito.mockFunction()
          toString:JsMockito.mockFunction()
        JsMockito.when(ret.toString)().then(()->
          fromString:ret
        )
        mockRoute = ret
        ret
      )
      mocks["backbone"].history.start = JsMockito.mockFunction()
      mocks["backbone"].history.getFragment = JsMockito.mockFunction()
      JsMockito.when(mocks["backbone"].history.getFragment)().then(()->"CURRENT_ROUTE_FRAGMENT")
    )

    suite("construction", ()->
      test("Binds to globalRouter navigate event with Route built from path", ()->

        JsMockito.verify(mockBackboneRouter.on)("route:navigate", new JsHamcrest.SimpleMatcher(
          matches:(h)->
            t = Router.trigger
            try
              Router.trigger = JsMockito.mockFunction()
              h("NEW_ROUTE")
              JsMockito.verify(Router.trigger)("navigate",JsHamcrest.Matchers.hasMember("builtWithPath","NEW_ROUTE"))
              true
            catch e
              false
            finally
              Router.trigger = t

        ))
      )
    )
    test("Activate starts backbone history", ()->
      Router.activate()
      JsMockito.verify(mocks["backbone"].history.start)()
    )
    suite("getCurrentRoute",()->

      test("Returns route created with current fragment", ()->

        ret = Router.getCurrentRoute()
        chai.assert.equal(ret.builtWithPath, "CURRENT_ROUTE_FRAGMENT")
      )

    )
    suite("getSubRoute", ()->
      test("Has subroute object with route name - returns named route", ()->
        JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
          ret =
            builtWithPath:s
            on:JsMockito.mockFunction()
            toString:JsMockito.mockFunction()
            subRoutes:
              MOCK_SUBROUTE_NAME:"MOCK_SUBROUTE_VALUE"
          JsMockito.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.equal(Router.getSubRoute("MOCK_SUBROUTE_NAME"), "MOCK_SUBROUTE_VALUE")
      )
      test("Has subroute object but no route with specified name - returns undefined", ()->
        JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
          ret =
            builtWithPath:s
            on:JsMockito.mockFunction()
            toString:JsMockito.mockFunction()
            subRoutes:{}
          JsMockito.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.isUndefined(Router.getSubRoute("MOCK_SUBROUTE_NAME"))
      )
      test("Has no subroute object - returns undefined", ()->
        JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
          ret =
            builtWithPath:s
            on:JsMockito.mockFunction()
            toString:JsMockito.mockFunction()
          JsMockito.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.isUndefined(Router.getSubRoute("MOCK_SUBROUTE_NAME"))
      )
    )
    suite("setSubRoute",()->
      setup(()->
        mockBackboneRouter.navigate = JsMockito.mockFunction()
      )
      test("Creates route with current fragment", ()->
        Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
        JsMockito.verify(mocks["UI/routing/Route"].func)("CURRENT_ROUTE_FRAGMENT")
      )
      test("Calls toString on route", ()->
        r = null
        JsMockito.when(mockBackboneRouter.navigate)(JsHamcrest.Matchers.anything()).then((ts)->
          r = ts.fromString
        )
        Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
        JsMockito.verify(r.toString)()
      )
      suite("Route has no sub route object", ()->
        test("Creates sub route object with route name property and route built from fragment as value, then uses routes toString output to navigate router", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("A_SUBROUTE",
                JsHamcrest.Matchers.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
        )
        test("No route does nothing", ()->
          Router.setSubRoute("A_SUBROUTE")
          JsMockito.verify(mockBackboneRouter.navigate, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )
      )
      suite("Route has sub route object but no existing subRoute matching input name", ()->
        setup(()->
          JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
            ret =
              builtWithPath:s
              on:JsMockito.mockFunction()
              toString:JsMockito.mockFunction()
              subRoutes:
                ANOTHER_SUBROUTE:"ANOTHER_FRAGMENT"
            JsMockito.when(ret.toString)().then(()->
              fromString:ret
            )
            mockRoute = ret
            ret
          )
        )
        test("Updates sub route object route name property and route built from fragment as value, then uses routes toString output to navigate router, leaving other subRoutes in place", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("A_SUBROUTE",
                JsHamcrest.Matchers.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")

            )
          ))
        )
        test("Options specified without trigger option - are passed to globalRouter with trigger set to true", ()->
          opt = opt1:"val1"
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT", opt)
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.allOf(JsHamcrest.Matchers.hasMember("opt1","val1"),JsHamcrest.Matchers.hasMember("trigger",true)))
        )
        test("Options specified with trigger option - are passed to globalRouter with trigger set as options", ()->
          opt =
            opt1:"val1"
            trigger:false
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT", opt)
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.allOf(JsHamcrest.Matchers.hasMember("opt1","val1"),JsHamcrest.Matchers.hasMember("trigger",false)))
        )
        test("Options not specified - passes trigger true option to globalRouter", ()->

          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.hasMember("trigger",true))
        )
        test("No route does nothing", ()->
          Router.setSubRoute("A_SUBROUTE")
          JsMockito.verify(mockBackboneRouter.navigate, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )

      )
      suite("Route has sub route object with subRoute matching input name", ()->
        setup(()->
          JsMockito.when(mocks["UI/routing/Route"].func)(JsHamcrest.Matchers.string()).then((s)->
            ret =
              builtWithPath:s
              on:JsMockito.mockFunction()
              toString:JsMockito.mockFunction()
              subRoutes:
                A_SUBROUTE:"NOT_A_PATH_FRAGMENT"
                ANOTHER_SUBROUTE:"ANOTHER_FRAGMENT"
            JsMockito.when(ret.toString)().then(()->
              fromString:ret
            )
            mockRoute = ret
            ret
          )
        )
        test("Replaces, then uses routes toString output to navigate router, leaving other subRoutes in place", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("A_SUBROUTE",
                JsHamcrest.Matchers.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")

            )
          ))
        )
        test("No route removes existing route, then navigates", ()->
          Router.setSubRoute("A_SUBROUTE")
          JsMockito.verify(mockBackboneRouter.navigate)(
            JsHamcrest.Matchers.hasMember("fromString",
              JsHamcrest.Matchers.hasMember("subRoutes",JsHamcrest.Matchers.not(
                JsHamcrest.Matchers.hasMember("A_SUBROUTE" )
              ))
            )
          )
          JsMockito.verify(mockBackboneRouter.navigate)(JsHamcrest.Matchers.hasMember("fromString",
            JsHamcrest.Matchers.hasMember("subRoutes",
              JsHamcrest.Matchers.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")
            )
          ))
        )
      )
      test("No route name throws", ()->
        chai.assert.throw(()->Router.setSubRoute(null, "A_PATH_FRAGMENT"))
      )
    )
  )
)

