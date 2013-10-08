


define(["isolate!UI/rivets/binders/FeedItem", "underscore", "rivets"], (FeedItem, _, rivets)->
  class FakeRivetsView
    constructor:(@template, @data, @options)->
      @template.withData = data
      @template.view = @
      @els=[template]
      @bind=JsMockito.mockFunction()
      @unbind=JsMockito.mockFunction()
      @update=JsMockito.mockFunction()



  class FakeDOMElement
    constructor:(stuff)->
      _.extend(@, stuff)
    removeChild:JsMockito.mockFunction()
    insertBefore:JsMockito.mockFunction()
    removeAttribute:JsMockito.mockFunction()
    cloneNode:(deep)->
      if deep then new FakeDOMElement(fromCloneNodeDeep:@) else new FakeDOMElement(fromCloneNodeShallow:@)

  suite("FeedItemTest", ()->
    fi=null
    el = new FakeDOMElement(
      parentNode:new FakeDOMElement(fromParentNode:@)
      nextSibling: new FakeDOMElement(fromNextSibling:@)

    )
    origRV = rivets._

    setup(
      ()->
        rivets._=
          View:FakeRivetsView
        fi = new FeedItem()
        fi.args=[
          "MOCK_ITEM_TYPE"
        ,
          "MOCK_ATTRIBUTE"
        ]
        fi.view = new FakeRivetsView({},{},{})
        fi.view.options =
          binders:"BINDER_VIEW_BINDERS"
          formatters:"BINDER_VIEW_BINDERS"
          config:
            prop1:'A'
            prop2:'B'
        fi.view.config =
          prefix:'prefix'
        fi.bind(new FakeDOMElement(
          parentNode:new FakeDOMElement(fromParentNode:@)
        ))

        fi.marker=new FakeDOMElement(
          parentNode:new FakeDOMElement(fromParentNode:@)
          nextSibling: new FakeDOMElement(
            fromNextSibling:@
            parentNode:new FakeDOMElement(fromParentNode:@)
            nextSibling: new FakeDOMElement(
              fromNextSibling:@
              parentNode:new FakeDOMElement(fromParentNode:@)
              nextSibling: new FakeDOMElement(
                fromNextSibling:@
                parentNode:new FakeDOMElement(fromParentNode:@)
                nextSibling: new FakeDOMElement(fromNextSibling:@)
              )
            )
          )
        )
    )
    teardown(
      ()->
        rivets._ = origRV
    )
    suite("bind", ()->

    )
    suite("routine", ()->
      setup(()->

        fi.marker.parentNode.removeChild = JsMockito.mockFunction()
        fi.marker.parentNode.insertBefore = JsMockito.mockFunction()
      )
      test("withoutBindingFirst_throws", ()->
        #reinitialise test binder without binding or setting marker
        fi = new FeedItem()
        fi.args=[
          "MOCK_ITEM_TYPE"
        ,
          "MOCK_ATTRIBUTE"
        ]
        fi.view = new FakeRivetsView({},{},{})
        fi.view.options =
          binders:"BINDER_VIEW_BINDERS"
          formatters:"BINDER_VIEW_BINDERS"
          config:
            prop1:'A'
            prop2:'B'
        chai.assert.throws(()->
          fi.routine(el,[
            MOCK_ATTRIBUTE:"MOCK_VAL1"
          ,
            MOCK_ATTRIBUTE:"MOCK_VAL2"

          ])
        )
      )
      test("emptyExistingEmptyNew_doesntChangeDOM", ()->
        fi.routine(el,[])
        JsMockito.verify(fi.marker.parentNode.removeChild, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("emptyExistingEmptyNew_LeavesIteratedEmpty", ()->
        fi.routine(el,[])
        chai.assert.equal(0, fi.iterated.length)
      )
      test("emptyExistingPopulatedNew_createsNewElementPerModel", ()->
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL1" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL2" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false
          )
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("emptyExistingPopulatedNew_populatesIterated", ()->
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        chai.assert.equal(2, fi.iterated.length)
        chai.assert.equal("MOCK_VAL1", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL2", fi.iterated[1].identifier)
      )
      test("populatedExistingEmptyNew_removesAndUnbindsExistingDOM", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[])
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        JsMockito.verify(itView1.unbind)()
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        JsMockito.verify(itView2.unbind)()
        JsMockito.verify(fi.marker.parentNode.insertBefore, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("populatedExistingEmptyNew_emptiesIterated", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[])
        chai.assert.equal(0, fi.iterated.length)
      )
      test("populatedExistingSameElementsInNew_OnlyUpdatesNoAddsRemovesOrRebinds", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        )
        JsMockito.verify(itView1.unbind, JsMockito.Verifiers.never())()
        JsMockito.verify(itView2.unbind, JsMockito.Verifiers.never())()
        JsMockito.verify(fi.marker.parentNode.insertBefore, JsMockito.Verifiers.never())(
          JsHamcrest.Matchers.anything()
        ,
          JsHamcrest.Matchers.anything()
        )
        JsMockito.verify(itView1.update)(JsHamcrest.Matchers.hasMember("MOCK_ITEM_TYPE", JsHamcrest.Matchers.hasMember("MOCK_ATTRIBUTE","MOCK_VAL1")))
        JsMockito.verify(itView2.update)(JsHamcrest.Matchers.hasMember("MOCK_ITEM_TYPE", JsHamcrest.Matchers.hasMember("MOCK_ATTRIBUTE","MOCK_VAL2")))
      )
      test("populatedExistingSameElementsInNew_leavesIteratedViewsTheSame", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        chai.assert.equal(2, fi.iterated.length)
        chai.assert.equal("MOCK_VAL1", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL2", fi.iterated[1].identifier)
        chai.assert.equal(itView1, fi.iterated[0].view)
        chai.assert.equal(itView2, fi.iterated[1].view)
      )
      test("populatedExistingDifferentElementsInNew_ReplacesAndRebinds", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL3"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL4"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        JsMockito.verify(itView1.unbind)()
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        JsMockito.verify(itView2.unbind)()

        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL4" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false
          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        JsMockito.verify(itView1.update, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        JsMockito.verify(itView2.update, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
      )
      test("populatedExistingSameElementsInNew_leavesIteratedViewsTheSame", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL3"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL4"

        ])
        chai.assert.equal(2, fi.iterated.length)
        chai.assert.equal("MOCK_VAL3", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL4", fi.iterated[1].identifier)
        chai.assert.notEqual(itView1, fi.iterated[0].view)
        chai.assert.notEqual(itView2, fi.iterated[1].view)
      )
      test("populatedExistingPartialOverlapInNew_UpdatesExistingCreatesNewDeletesMissing", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        JsMockito.verify(itView1.unbind)()
        JsMockito.verify(fi.marker.parentNode.removeChild, JsMockito.Verifiers.never())(
          itView2.els[0]
        )
        JsMockito.verify(itView2.unbind,JsMockito.Verifiers.never())()

        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        JsMockito.verify(itView2.update)()
      )
      test("populatedExistingPartialOverlapInNew_MakesIteratedLikeNewPreservingThoseRetained", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"

        ])
        chai.assert.equal(2, fi.iterated.length)
        chai.assert.equal("MOCK_VAL2", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL3", fi.iterated[1].identifier)
        chai.assert.equal(itView2, fi.iterated[0].view)
      )

      test("populatedExistingPartialOverlapInNewWithAdditionsAndSubtractionsInMiddle_UpdatesExistingCreatesNewDeletesMissing", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        itView4 = new FakeRivetsView({b:2},{},{})
        itView5 = new FakeRivetsView({a:1},{},{})

        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ,
          identifier:"MOCK_VAL4"
          view:itView4
        ,
          identifier:"MOCK_VAL5"
          view:itView5
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL5"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL6"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        JsMockito.verify(itView1.unbind)()
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView4.els[0]
        )
        JsMockito.verify(itView4.unbind)()

        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL6" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling.nextSibling.nextSibling
        )
        JsMockito.verify(itView2.update)()
        JsMockito.verify(itView5.update)()
      )
      test("populatedExistingPartialOverlapInNewWithAdditionsAndSubtractionsInMiddle_preservesUpdatedViewsInIteratedAndPreservesOrdering", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        itView4 = new FakeRivetsView({b:2},{},{})
        itView5 = new FakeRivetsView({a:1},{},{})

        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ,
          identifier:"MOCK_VAL4"
          view:itView4
        ,
          identifier:"MOCK_VAL5"
          view:itView5
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL5"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL6"

        ])
        chai.assert.equal(4, fi.iterated.length)
        chai.assert.equal("MOCK_VAL2", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL3", fi.iterated[1].identifier)
        chai.assert.equal("MOCK_VAL5", fi.iterated[2].identifier)
        chai.assert.equal("MOCK_VAL6", fi.iterated[3].identifier)
        chai.assert.equal(itView2, fi.iterated[0].view)
        chai.assert.equal(itView5, fi.iterated[2].view)
      )

      test("elementsReordered_preservesElemenrtsAsEncounteredInOriginalOrderingAndRecreatesTheRest", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        itView3 = new FakeRivetsView({b:2},{},{})
        itView4 = new FakeRivetsView({a:1},{},{})

        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ,
          identifier:"MOCK_VAL3"
          view:itView3
        ,
          identifier:"MOCK_VAL4"
          view:itView4
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL4"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"

        ])
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        JsMockito.verify(itView2.unbind)()
        JsMockito.verify(fi.marker.parentNode.removeChild)(
          itView4.els[0]
        )
        JsMockito.verify(itView4.unbind)()

        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL2" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        JsMockito.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL4" then false
              try
                JsMockito.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling.nextSibling
        )
        JsMockito.verify(itView1.update)()
        JsMockito.verify(itView3.update)()
      )

      test("elementsReordered_reordersAndPreservesTheSameInIteratedAsElements", ()->
        itView1 = new FakeRivetsView({b:2},{},{})
        itView2 = new FakeRivetsView({a:1},{},{})
        itView3 = new FakeRivetsView({b:2},{},{})
        itView4 = new FakeRivetsView({a:1},{},{})

        fi.iterated = [
          identifier:"MOCK_VAL1"
          view:itView1
        ,
          identifier:"MOCK_VAL2"
          view:itView2
        ,
          identifier:"MOCK_VAL3"
          view:itView3
        ,
          identifier:"MOCK_VAL4"
          view:itView4
        ]
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL2"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL4"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL3"

        ])
        chai.assert.equal(4, fi.iterated.length)
        chai.assert.equal("MOCK_VAL2", fi.iterated[0].identifier)
        chai.assert.equal("MOCK_VAL1", fi.iterated[1].identifier)
        chai.assert.equal("MOCK_VAL4", fi.iterated[2].identifier)
        chai.assert.equal("MOCK_VAL3", fi.iterated[3].identifier)
        chai.assert.equal(itView1, fi.iterated[1].view)
        chai.assert.equal(itView3, fi.iterated[3].view)
        chai.assert.notEqual(itView2, fi.iterated[0].view)
        chai.assert.notEqual(itView4, fi.iterated[2].view)
      )
    )
  )


)

