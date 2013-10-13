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

define(["isolate!UI/component/BaseView"], (BaseView)->
    #BaseViewTest.coffee test file    

    mocks = window.mockLibrary["UI/component/BaseView"];
    suite("BaseView", ()->
        suite("constructor", ()->
            test("setsTemplate", ()->
                #implement test
                bv = new BaseView(
                    template:"TEST_TEMPLATE"
                )
                chai.assert.equal(bv.template, "TEST_TEMPLATE")
            )
            test("setsRootSelector", ()->
            #implement test
                bv = new BaseView(
                    rootSelector:"TEST_SELECTOR"
                )
                chai.assert.equal(bv.rootSelector, "TEST_SELECTOR")
            )
        )
        suite("render", ()->
          test("callsCreateModelOnDerivedType",()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"

            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(bv.createModel)()
          )
          test("bindsUsingRootSelectorsFirstChild",()->
            bv = new BaseView(
             rootSelector:"TEST_SELECTOR"
            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(mocks.jqueryObjects["TEST_SELECTOR"].children)()
            JsMockito.verify(mocks.jqueryObjects.methodResults.children.first)()
            JsMockito.verify(mocks.rivets.bind)(mocks.jqueryObjects.methodResults.first,JsHamcrest.Matchers.anything())
          )
          test("attachesTemplateToRootSelectorNode", ()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
              template:"MOCK_TEMPLATE"
            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(mocks.jqueryObjects["TEST_SELECTOR"]).html("MOCK_TEMPLATE")
          )
          test("setsView", ()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            chai.assert.equal(bv.view.id, "MOCK_RIVETS_VIEW")
            chai.assert.equal(bv.view.selector, mocks.jqueryObjects.methodResults.first)
          )
          test("sets$elToRootSelectorResult", ()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            chai.assert.equal(bv.$el, mocks.jqueryObjects["TEST_SELECTOR"])
          )

          test("undelegatesExistingEvents", ()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
            )
            if (bv.undelegateEvents)
              bv.undelegateEvents= JsMockito.mockFunction()
            else
              chai.assert(false,"Base Views should support undelegateEvents method")
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(bv.undelegateEvents)()
          )

          test("delegatesEventsObject", ()->
            ev={}
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
              events:ev
            )
            if (bv.delegateEvents)
              bv.delegateEvents= JsMockito.mockFunction()
            else
              chai.assert(false, "Base Views should support delegateEvents method")
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(bv.delegateEvents)(ev)
          )

          test("delegatesUndefinedIfEventNotDefined", ()->
            ev={}
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
            )
            if (bv.delegateEvents)
              bv.delegateEvents= JsMockito.mockFunction()
            else
              chai.assert(false, "Base Views should support delegateEvents method")
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(bv.delegateEvents)(JsHamcrest.Matchers.nil())
          )
        )
        suite("createModel", ()->
          test("throwsIfNotOverriden", ()->
            bv = new BaseView(
              rootSelector:"TEST_SELECTOR"
            )
            chai.assert.throw(()->
              bv.createModel()
            )

          )
        )
    )


)