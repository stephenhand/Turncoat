

define(["isolate!UI/BaseView"], (BaseView)->
    #BaseViewTest.coffee test file    

    mocks = window.mockLibrary["UI/BaseView"];
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
          test("bindsUsingRootSelector",()->
            bv = new BaseView(
             rootSelector:"TEST_SELECTOR"
            )
            bv.createModel=JsMockito.mockFunction()
            bv.render()
            JsMockito.verify(mocks.rivets.bind)(mocks.jqueryObjects["TEST_SELECTOR"],JsHamcrest.Matchers.anything())
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
            chai.assert.equal(bv.view.selector, mocks.jqueryObjects["TEST_SELECTOR"])
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