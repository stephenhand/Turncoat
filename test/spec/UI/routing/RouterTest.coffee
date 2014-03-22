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
define(["isolate!UI/routing/Router", "jsMockito", "jsHamcrest", "chai"], (Router, jm, h, c)->
  mocks=window.mockLibrary['UI/routing/Router']     
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("Router", ()->
    setup(()->
      mocks["UI/routing/Route"].func = jm.mockFunction()
      jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
        ret =
          builtWithPath:s
          on:jm.mockFunction()
          toString:jm.mockFunction()
        jm.when(ret.toString)().then(()->
          fromString:ret
        )
        mockRoute = ret
        ret
      )
      mocks["backbone"].history.start = jm.mockFunction()
      mocks["backbone"].history.getFragment = jm.mockFunction()
      jm.when(mocks["backbone"].history.getFragment)().then(()->"CURRENT_ROUTE_FRAGMENT")
    )

    suite("construction", ()->
      test("Binds to globalRouter navigate event with Route built from path", ()->

        jm.verify(mockBackboneRouter.on)("route:navigate", new h.SimpleMatcher(
          matches:(h)->
            t = Router.trigger
            try
              Router.trigger = jm.mockFunction()
              h("NEW_ROUTE")
              jm.verify(Router.trigger)("navigate",m.hasMember("builtWithPath","NEW_ROUTE"))
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
      jm.verify(mocks["backbone"].history.start)()
    )
    suite("getCurrentRoute",()->

      test("Returns route created with current fragment", ()->

        ret = Router.getCurrentRoute()
        chai.assert.equal(ret.builtWithPath, "CURRENT_ROUTE_FRAGMENT")
      )

    )
    suite("setRoute",()->
      r = null
      setup(()->
        r =
          toString:jm.mockFunction()
        jm.when(r.toString)().then(()->"RESOLVED ROUTE")
        mockBackboneRouter.navigate = jm.mockFunction()
      )
      test("Calls toString on route", ()->
        Router.setRoute(r)
        jm.verify(r.toString)()
      )
      test("Navigates to resolved route with trigger option set", ()->
        Router.setRoute(r)
        jm.verify(mockBackboneRouter.navigate)("RESOLVED ROUTE",m.hasMember("trigger",true))
      )

    )
    suite("getSubRoute", ()->
      test("Has subroute object with route name - returns named route", ()->
        jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
          ret =
            builtWithPath:s
            on:jm.mockFunction()
            toString:jm.mockFunction()
            subRoutes:
              MOCK_SUBROUTE_NAME:"MOCK_SUBROUTE_VALUE"
          jm.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.equal(Router.getSubRoute("MOCK_SUBROUTE_NAME"), "MOCK_SUBROUTE_VALUE")
      )
      test("Has subroute object but no route with specified name - returns undefined", ()->
        jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
          ret =
            builtWithPath:s
            on:jm.mockFunction()
            toString:jm.mockFunction()
            subRoutes:{}
          jm.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.isUndefined(Router.getSubRoute("MOCK_SUBROUTE_NAME"))
      )
      test("Has no subroute object - returns undefined", ()->
        jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
          ret =
            builtWithPath:s
            on:jm.mockFunction()
            toString:jm.mockFunction()
          jm.when(ret.toString)().then(()->
            fromString:ret
          )
          ret
        )
        chai.assert.isUndefined(Router.getSubRoute("MOCK_SUBROUTE_NAME"))
      )
    )
    suite("setSubRoute",()->
      setup(()->
        mockBackboneRouter.navigate = jm.mockFunction()
      )
      test("Creates route with current fragment", ()->
        Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
        jm.verify(mocks["UI/routing/Route"].func)("CURRENT_ROUTE_FRAGMENT")
      )
      test("Calls toString on route", ()->
        r = null
        jm.when(mockBackboneRouter.navigate)(m.anything()).then((ts)->
          r = ts.fromString
        )
        Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
        jm.verify(r.toString)()
      )
      suite("Route has no sub route object", ()->
        test("Creates sub route object with route name property and route built from fragment as value, then uses routes toString output to navigate router", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("A_SUBROUTE",
                m.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
        )
        test("No route does nothing", ()->
          Router.setSubRoute("A_SUBROUTE")
          jm.verify(mockBackboneRouter.navigate, v.never())(m.anything())
        )
      )
      suite("Route has sub route object but no existing subRoute matching input name", ()->
        setup(()->
          jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
            ret =
              builtWithPath:s
              on:jm.mockFunction()
              toString:jm.mockFunction()
              subRoutes:
                ANOTHER_SUBROUTE:"ANOTHER_FRAGMENT"
            jm.when(ret.toString)().then(()->
              fromString:ret
            )
            mockRoute = ret
            ret
          )
        )
        test("Updates sub route object route name property and route built from fragment as value, then uses routes toString output to navigate router, leaving other subRoutes in place", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("A_SUBROUTE",
                m.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")

            )
          ))
        )
        test("Options specified without trigger option - are passed to globalRouter with trigger set to true", ()->
          opt = opt1:"val1"
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT", opt)
          jm.verify(mockBackboneRouter.navigate)(m.anything(), m.allOf(m.hasMember("opt1","val1"),m.hasMember("trigger",true)))
        )
        test("Options specified with trigger option - are passed to globalRouter with trigger set as options", ()->
          opt =
            opt1:"val1"
            trigger:false
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT", opt)
          jm.verify(mockBackboneRouter.navigate)(m.anything(), m.allOf(m.hasMember("opt1","val1"),m.hasMember("trigger",false)))
        )
        test("Options not specified - passes trigger true option to globalRouter", ()->

          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          jm.verify(mockBackboneRouter.navigate)(m.anything(), m.hasMember("trigger",true))
        )
        test("No route does nothing", ()->
          Router.setSubRoute("A_SUBROUTE")
          jm.verify(mockBackboneRouter.navigate, v.never())(m.anything())
        )

      )
      suite("Route has sub route object with subRoute matching input name", ()->
        setup(()->
          jm.when(mocks["UI/routing/Route"].func)(m.string()).then((s)->
            ret =
              builtWithPath:s
              on:jm.mockFunction()
              toString:jm.mockFunction()
              subRoutes:
                A_SUBROUTE:"NOT_A_PATH_FRAGMENT"
                ANOTHER_SUBROUTE:"ANOTHER_FRAGMENT"
            jm.when(ret.toString)().then(()->
              fromString:ret
            )
            mockRoute = ret
            ret
          )
        )
        test("Replaces, then uses routes toString output to navigate router, leaving other subRoutes in place", ()->
          Router.setSubRoute("A_SUBROUTE", "A_PATH_FRAGMENT")
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("A_SUBROUTE",
                m.hasMember("builtWithPath","A_PATH_FRAGMENT")
              )
            )
          ))
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")

            )
          ))
        )
        test("No route removes existing route, then navigates", ()->
          Router.setSubRoute("A_SUBROUTE")
          jm.verify(mockBackboneRouter.navigate)(
            m.hasMember("fromString",
              m.hasMember("subRoutes",m.not(
                m.hasMember("A_SUBROUTE" )
              ))
            )
          )
          jm.verify(mockBackboneRouter.navigate)(m.hasMember("fromString",
            m.hasMember("subRoutes",
              m.hasMember("ANOTHER_SUBROUTE","ANOTHER_FRAGMENT")
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

