


define(["isolate!UI/rivets/binders/FeedItem", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "underscore", "rivets"], (FeedItem, m, o, a, jm, v, _, rivets)->
  class FakeRivetsView
    constructor:(@template, @data, @options)->
      @template.withData = data
      @template.view = @
      @els=[template]
      @bind=jm.mockFunction()
      @unbind=jm.mockFunction()
      @update=jm.mockFunction()



  class FakeDOMElement
    constructor:(stuff)->
      _.extend(@, stuff)
    removeChild:jm.mockFunction()
    insertBefore:jm.mockFunction()
    removeAttribute:jm.mockFunction()
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
          "MOCK_ITEM_TYPE-MOCK_ATTRIBUTE"
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

        fi.marker.parentNode.removeChild = jm.mockFunction()
        fi.marker.parentNode.insertBefore = jm.mockFunction()
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
        a(()->
          fi.routine(el,[
            MOCK_ATTRIBUTE:"MOCK_VAL1"
          ,
            MOCK_ATTRIBUTE:"MOCK_VAL2"

          ])
        ,
          m.raisesAnything()
        )
      )
      test("emptyExistingEmptyNew_doesntChangeDOM", ()->
        fi.routine(el,[])
        jm.verify(fi.marker.parentNode.removeChild, v.never())(
          m.anything()
        )
        jm.verify(fi.marker.parentNode.insertBefore, v.never())(
          m.anything()
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("emptyExistingEmptyNew_LeavesIteratedEmpty", ()->
        fi.routine(el,[])
        a(0, fi.iterated.length)
      )
      test("emptyExistingPopulatedNew_createsNewElementPerModel", ()->
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        jm.verify(fi.marker.parentNode.removeChild, v.never())(
          m.anything()
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL1" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL2" then false
              try
                jm.verify(template.view.bind)()
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
        a(2, fi.iterated.length)
        a("MOCK_VAL1", fi.iterated[0].identifier)
        a("MOCK_VAL2", fi.iterated[1].identifier)
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
        jm.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        jm.verify(itView1.unbind)()
        jm.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        jm.verify(itView2.unbind)()
        jm.verify(fi.marker.parentNode.insertBefore, v.never())(
          m.anything()
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
        a(0, fi.iterated.length)
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
        jm.verify(fi.marker.parentNode.removeChild, v.never())(
          m.anything()
        )
        jm.verify(itView1.unbind, v.never())()
        jm.verify(itView2.unbind, v.never())()
        jm.verify(fi.marker.parentNode.insertBefore, v.never())(
          m.anything()
        ,
          m.anything()
        )
        jm.verify(itView1.update)(m.hasMember("MOCK_ITEM_TYPE", m.hasMember("MOCK_ATTRIBUTE","MOCK_VAL1")))
        jm.verify(itView2.update)(m.hasMember("MOCK_ITEM_TYPE", m.hasMember("MOCK_ATTRIBUTE","MOCK_VAL2")))
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
        a(2, fi.iterated.length)
        a("MOCK_VAL1", fi.iterated[0].identifier)
        a("MOCK_VAL2", fi.iterated[1].identifier)
        a(itView1, fi.iterated[0].view)
        a(itView2, fi.iterated[1].view)
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
        jm.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        jm.verify(itView1.unbind)()
        jm.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        jm.verify(itView2.unbind)()

        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL4" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false
          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        jm.verify(itView1.update, v.never())(m.anything())
        jm.verify(itView2.update, v.never())(m.anything())
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
        a(2, fi.iterated.length)
        a("MOCK_VAL3", fi.iterated[0].identifier)
        a("MOCK_VAL4", fi.iterated[1].identifier)
        a(itView1, m.not(fi.iterated[0].view))
        a(itView2, m.not(fi.iterated[1].view))
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
        jm.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        jm.verify(itView1.unbind)()
        jm.verify(fi.marker.parentNode.removeChild, v.never())(
          itView2.els[0]
        )
        jm.verify(itView2.unbind,v.never())()

        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        jm.verify(itView2.update)()
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
        a(2, fi.iterated.length)
        a("MOCK_VAL2", fi.iterated[0].identifier)
        a("MOCK_VAL3", fi.iterated[1].identifier)
        a(itView2, fi.iterated[0].view)
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
        jm.verify(fi.marker.parentNode.removeChild)(
          itView1.els[0]
        )
        jm.verify(itView1.unbind)()
        jm.verify(fi.marker.parentNode.removeChild)(
          itView4.els[0]
        )
        jm.verify(itView4.unbind)()

        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL3" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL6" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling.nextSibling.nextSibling
        )
        jm.verify(itView2.update)()
        jm.verify(itView5.update)()
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
        a(4, fi.iterated.length)
        a("MOCK_VAL2", fi.iterated[0].identifier)
        a("MOCK_VAL3", fi.iterated[1].identifier)
        a("MOCK_VAL5", fi.iterated[2].identifier)
        a("MOCK_VAL6", fi.iterated[3].identifier)
        a(itView2, fi.iterated[0].view)
        a(itView5, fi.iterated[2].view)
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
        jm.verify(fi.marker.parentNode.removeChild)(
          itView2.els[0]
        )
        jm.verify(itView2.unbind)()
        jm.verify(fi.marker.parentNode.removeChild)(
          itView4.els[0]
        )
        jm.verify(itView4.unbind)()

        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL2" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              if template.withData?.MOCK_ITEM_TYPE?.MOCK_ATTRIBUTE is "MOCK_VAL4" then false
              try
                jm.verify(template.view.bind)()
                true
              catch e
                false

          )
        ,
          fi.marker.nextSibling.nextSibling.nextSibling
        )
        jm.verify(itView1.update)()
        jm.verify(itView3.update)()
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
        a(4, fi.iterated.length)
        a("MOCK_VAL2", fi.iterated[0].identifier)
        a("MOCK_VAL1", fi.iterated[1].identifier)
        a("MOCK_VAL4", fi.iterated[2].identifier)
        a("MOCK_VAL3", fi.iterated[3].identifier)
        a(itView1, fi.iterated[1].view)
        a(itView3, fi.iterated[3].view)
        a(itView2, m.not(fi.iterated[0].view))
        a(itView4, m.not(fi.iterated[2].view))
      )

      test("populatedNew_copiesConfigSettingsFromBinderViewToNewViews", ()->
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.options.config.prop1 is "A" and template.view.options.config.prop2 is "B"

          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.options.config.prop1 is "A" and template.view.options.config.prop2 is "B"

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("populatedNew_setsPreloadConfigOptionTrueOnAllNewViews", ()->
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.options.config.preloadData is true

          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.options.config.preloadData is true

          )
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("populatedNew_copiesDataFromBinderViewModels", ()->
        fi.view.models =
          A:1
          B:2
          C:3
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.data.A is 1 and template.view.data.B is 2 and template.view.data.C is 3
          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.data.A is 1 and template.view.data.B is 2 and template.view.data.C is 3
          )
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("populatedNew_copiesAttributeMatchingModelNameFromCollectionNotViewModels", ()->
        fi.view.models =
          A:1
          B:2
          C:3
          MOCK_ITEM_TYPE:"CHEESE"
        fi.bind()
        fi.routine(el,[
          MOCK_ATTRIBUTE:"MOCK_VAL1"
        ,
          MOCK_ATTRIBUTE:"MOCK_VAL2"

        ])
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.data.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL1"
          )
        ,
          fi.marker.nextSibling
        )
        jm.verify(fi.marker.parentNode.insertBefore)(
          new JsHamcrest.SimpleMatcher(
            matches:(template)->
              template.view.data.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL2"
          )
        ,
          fi.marker.nextSibling.nextSibling
        )
      )
      test("updateExistingElements_updatesExistingSubViewsWithNewDataOnly", ()->
        fi.view.models =
          A:1
          B:2
          C:3
          MOCK_ITEM_TYPE:"CHEESE"
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
        jm.verify(itView1.update)(new JsHamcrest.SimpleMatcher(
          matches:(d)->
            d.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL1" and !d.A? and !d.B? and !d.C?
        ))
        jm.verify(itView2.update)(new JsHamcrest.SimpleMatcher(
          matches:(d)->
            d.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL2" and !d.A? and !d.B? and !d.C?
        ))
      )

    )
    suite("update", ()->

    )
  )


)

