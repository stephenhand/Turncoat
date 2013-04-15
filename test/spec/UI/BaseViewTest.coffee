

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
            test("bindsUsingRootSelector",()->
                bv = new BaseView(
                 rootSelector:"TEST_SELECTOR"
                )
                bv.render()
                verify(mocks.rivets.bind)("TEST_SELECTOR",JsHamcrest.Matchers.anything())
            )
            test("setsView", ()->
                bv = new BaseView(
                  rootSelector:"TEST_SELECTOR"
                )
                bv.render()
                chai.assert.equal(bv.view.id, "MOCK_RIVETS_VIEW")
                chai.assert.equal(bv.view.selector, "TEST_SELECTOR")
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