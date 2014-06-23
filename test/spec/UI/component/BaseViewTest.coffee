require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("lib/2D/PolygonTools","UI/component/BaseView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockPolygonTools =
        pointInPoly:(poly,x,y)->
          mockPolygonTools
    )
  )


  Isolate.mapAsFactory("rivets","UI/component/BaseView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        bind:JsMockito.mockFunction()
      JsMockito.when(stubRivets.bind)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
        (selector, model)->
          id:"MOCK_RIVETS_VIEW"
          selector:selector
      )
      stubRivets
    )
  )

  Isolate.mapAsFactory("lib/2D/PolygonTools","UI/component/BaseView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockPolygonTools =
        pointInPoly:(poly,x,y)->
          mockPolygonTools
    )
  )
)

define(["isolate!UI/component/BaseView", "matchers", "operators", "assertThat","jsMockito", "verifiers"], (BaseView, m, o, a, jm, v)->
    #BaseViewTest.coffee test file    

    mocks = window.mockLibrary["UI/component/BaseView"];
    suite("BaseView", ()->
      setup(()->
        mocks.jqueryObjects = []
      )
      suite("constructor", ()->
        test("setsTemplate", ()->
          bv = new BaseView(
              template:"TEST_TEMPLATE"
          )
          a(bv.template, "TEST_TEMPLATE")
        )
        test("setsRootSelector", ()->
          bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
          )
          a(bv.rootSelector, "TEST_SELECTOR")
        )
      )
      suite("render", ()->
        test("callsCreateModelOnDerivedType",()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"

          )
          bv.createModel=jm.mockFunction()
          bv.render()
          jm.verify(bv.createModel)()
        )
        test("bindsUsingRootSelectorsFirstChild",()->
          bv = new BaseView(
           rootSelector:"TEST_SELECTOR"
          )
          bv.createModel=jm.mockFunction()
          bv.render()
          jm.verify(mocks.jqueryObjects["TEST_SELECTOR"].children)()
          jm.verify(mocks.jqueryObjects.methodResults.children.first)()
          jm.verify(mocks.rivets.bind)(mocks.jqueryObjects.methodResults.first,m.anything())
        )
        test("attachesTemplateToRootSelectorNode", ()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
            template:"MOCK_TEMPLATE"
          )
          bv.createModel=jm.mockFunction()
          bv.render()
          jm.verify(mocks.jqueryObjects["TEST_SELECTOR"]).html("MOCK_TEMPLATE")
        )
        test("setsView", ()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.createModel=jm.mockFunction()
          bv.render()
          a(bv.view.id, "MOCK_RIVETS_VIEW")
          a(bv.view.selector, mocks.jqueryObjects.methodResults.first)
        )
        test("sets$elToRootSelectorResult", ()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.createModel=jm.mockFunction()
          bv.render()
          a(bv.$el, mocks.jqueryObjects["TEST_SELECTOR"])
        )

        test("undelegatesExistingEvents", ()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          if (bv.undelegateEvents)
            bv.undelegateEvents= jm.mockFunction()
          else
            a(false,"Base Views should support undelegateEvents method")
          bv.createModel=JsMockito.mockFunction()
          bv.render()
          jm.verify(bv.undelegateEvents)()
        )

        test("delegatesEventsObject", ()->
          ev={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
            events:ev
          )
          if (bv.delegateEvents)
            bv.delegateEvents= jm.mockFunction()
          else
            a(false, "Base Views should support delegateEvents method")
          bv.createModel=jm.mockFunction()
          bv.render()
          jm.verify(bv.delegateEvents)(ev)
        )

        test("delegatesUndefinedIfEventNotDefined", ()->
          ev={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          if (bv.delegateEvents)
            bv.delegateEvents= jm.mockFunction()
          else
            a(false, "Base Views should support delegateEvents method")
          bv.createModel=jm.mockFunction()
          bv.render()
          jm.verify(bv.delegateEvents)(m.nil())
        )
      )
      suite("createModel", ()->
        test("throwsIfNotOverriden", ()->
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          a(()->
            bv.createModel()
          ,
            m.raisesAnything()
          )

        )
      )
      suite("routeChanged", ()->
        test("subViewsSetAsBackboneModel_callsAllSubviewsWithSameRoute", ()->
          route ={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.subViews = new Backbone.Model(
            SUBVIEW1:new BaseView(rootSelector:"TEST_SELECTOR")
            SUBVIEW2:new BaseView(rootSelector:"TEST_SELECTOR")
            SUBVIEW3:new BaseView(rootSelector:"TEST_SELECTOR")
          )
          bv.subViews.get("SUBVIEW1").routeChanged = jm.mockFunction()
          bv.subViews.get("SUBVIEW2").routeChanged = jm.mockFunction()
          bv.subViews.get("SUBVIEW3").routeChanged = jm.mockFunction()
          bv.routeChanged(route)
          jm.verify(bv.subViews.get("SUBVIEW1").routeChanged)(route)
          jm.verify(bv.subViews.get("SUBVIEW2").routeChanged)(route)
          jm.verify(bv.subViews.get("SUBVIEW3").routeChanged)(route)

        )

        test("subviewsSetAsBackboneModel_IgnoresNonBaseViews", ()->
          route ={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.subViews = new Backbone.Model(
            SUBVIEW1:new BaseView(rootSelector:"TEST_SELECTOR")
            SUBVIEW2:new BaseView(rootSelector:"TEST_SELECTOR")
            NOTAVIEW:{}
            SUBVIEW3:new BaseView(rootSelector:"TEST_SELECTOR")
            NOTAVIEW2:{}
          )
          bv.subViews.get("SUBVIEW1").routeChanged = jm.mockFunction()
          bv.subViews.get("SUBVIEW2").routeChanged = jm.mockFunction()
          bv.subViews.get("SUBVIEW3").routeChanged = jm.mockFunction()
          bv.routeChanged(route)
          jm.verify(bv.subViews.get("SUBVIEW1").routeChanged)(route)
          jm.verify(bv.subViews.get("SUBVIEW2").routeChanged)(route)
          jm.verify(bv.subViews.get("SUBVIEW3").routeChanged)(route)
        )

        test("subviewsNotSet_Throws", ()->
          route ={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.subViews = undefined
          a(
            ()->bv.routeChanged(route)
          ,
            m.raisesAnything())

        )

        test("subviewsNotBackboneModel_DoesNothing", ()->
          route ={}
          bv = new BaseView(
            rootSelector:"TEST_SELECTOR"
          )
          bv.subViews = {}
          a(
            ()->bv.routeChanged(route)
          ,
            m.not(m.raisesAnything())
          )

        )
      )
    )


)