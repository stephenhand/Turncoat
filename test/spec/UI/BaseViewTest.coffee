

define(["isolate!UI/BaseView"], (BaseView)->
    #BaseViewTest.coffee test file    
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
            test("",()->
              bv = new BaseView(
               rootSelector:"TEST_SELECTOR"
              )
            )
        )
    )


)