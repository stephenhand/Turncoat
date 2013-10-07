


define(["isolate!UI/rivets/binders/FeedItem", "underscore", "rivets"], (FeedItem, _, rivets)->
  class FakeRivetsView
    constructor:(@template, @data, @options)->
      template.withData = data
      els=[template]
    bind:JsMockito.mockFunction()
    unbind:JsMockito.mockFunction()
    els:[]


  class FakeDOMElement
    constructor:(stuff)->
      _.extend(@, stuff)
    removeChild:JsMockito.mockFunction()
    insertBefore:JsMockito.mockFunction()
    cloneNode:(deep)->
      if deep then new FakeDOMElement(fromCloneNodeDeep:@) else new FakeDOMElement(fromCloneNodeShallow:@)

  suite("FeedItemTest", ()->
    fi=null
    el = new FakeDOMElement(
      parentNode:new FakeDOMElement(fromParentNode:@)
      nextSibling: new FakeDOMElement(fromNextSibling:@)
    )
    origRV = rivets.View

    setup(
      ()->
        rivets.View = FakeRivetsView
        fi = new FeedItem()
        fi.args=[
          "MOCK_ITEM_TYPE"
        ,
          "MOCK_ATTRIBUTE"
        ]
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
        fi.view = new FakeRivetsView({},{},{})
        fi.view.options =
          binders:"BINDER_VIEW_BINDERS"
          formatters:"BINDER_VIEW_BINDERS"
          config:
            prop1:'A'
            prop2:'B'
    )
    teardown(
      ()->
        rivets.View = origRV
    )
    suite("routine", ()->
      test("withoutBindingFirst_throws", ()->
        chai.assert.throws(()->
          fi.routine(el,[
            MOCK_ATTRIBUTE:"MOCK_VAL1"
          ,
            MOCK_ATTRIBUTE:"MOCK_VAL2"

          ])
        )
      )
#      test("emptyExistingPopulatedNew_createsNewElementPerModel", ()->
#        fi.bind()
#        fi.routine(el,[
#          MOCK_ATTRIBUTE:"MOCK_VAL1"
#        ,
#          MOCK_ATTRIBUTE:"MOCK_VAL2"
#
#        ])
#        JsMockito.verify(fi.marker.parentNode.insertBefore)(
#          new SimpleMatcher(
#            matches:(template)->
#              template.withData.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL1"
#          )
#        ,
#          fi.marker.nextSibling
#        )
#        JsMockito.verify(fi.marker.parentNode.insertBefore)(
#          new SimpleMatcher(
#            matches:(template)->
#              template.withData.MOCK_ITEM_TYPE.MOCK_ATTRIBUTE is "MOCK_VAL2"
#          )
#        ,
#          fi.marker.nextSibling.nextSibling
#        )
#      )
    )
  )


)

