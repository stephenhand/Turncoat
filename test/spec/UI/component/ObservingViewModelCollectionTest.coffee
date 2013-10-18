define(['isolate!UI/component/ObservingViewModelCollection'], (ObservingViewModelCollection)->
  suite("ObservingViewModelCollection", ()->
    coll1 = coll2 = coll3 = coll4 = coll5 = null
    bvmc=null
    mockOnSourceUpdatedHandler = null
    mockOnSourceUpdatedHandler2 = null
    onsourceupdatedHandlerMatcher = null
    setup(()->
      invokes = 0
      mockOnSourceUpdatedHandler = JsMockito.mockFunction()
      onsourceupdatedHandlerMatcher = new JsHamcrest.SimpleMatcher(
        describeTo:(d)->"OnSourceUpdated Handler"
        matches:(input)->
          input()
          try
            JsMockito.verify(mockOnSourceUpdatedHandler, JsMockito.Verifiers.times(++invokes))()
            true
          catch e
            false
      )
      onsourceupdatedHandlerMatcher.handlerToCheck=mockOnSourceUpdatedHandler
      bvmc = new ObservingViewModelCollection()
      bvmc.onSourceUpdated = mockOnSourceUpdatedHandler

      coll1 = {}
      _.extend(coll1, Backbone.Events)
      coll1.on=JsMockito.mockFunction()
      coll1.off=JsMockito.mockFunction()

      coll2 =
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      coll3 =
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      coll4 =
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      coll5 =
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
    )
    suite("watch", ()->

      test("singleCollection_BindsOnSourceUpdatedToCollectionAddEvent", ()->

        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("add", onsourceupdatedHandlerMatcher)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionAddEvent", ()->
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.on)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.on)("add", onsourceupdatedHandlerMatcher)
      )

      test("singleCollection_BindsOnSourceUpdatedToCollectionRemoveEvent", ()->
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("remove", onsourceupdatedHandlerMatcher)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionRemoveEvent", ()->
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.on)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.on)("remove", onsourceupdatedHandlerMatcher)
      )

      test("singleCollection_BindsOnSourceUpdatedToCollectionResetEvent", ()->
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("reset", onsourceupdatedHandlerMatcher)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionResetEvent", ()->
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.on)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.on)("reset", onsourceupdatedHandlerMatcher)
      )

      test("singleCollection_DoesntDupBinds", ()->
        bvmc.watch([coll1])
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
      )
      test("multipleCollections_DoesntDupBinds", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
      )
      test("reassigningHandlerAfterWatch_CallsUpdatedHandler", ()->

        mockOnSourceUpdatedHandler2 = JsMockito.mockFunction()
        mockOnSourceUpdatedHandler3 = JsMockito.mockFunction()
        coll = {}
        _.extend(coll, Backbone.Events)
        bvmc.watch([coll])
        bvmc.onSourceUpdated = mockOnSourceUpdatedHandler2
        coll.trigger("reset")
        JsMockito.verify(mockOnSourceUpdatedHandler2)()
        bvmc.onSourceUpdated = mockOnSourceUpdatedHandler3
        coll.trigger("reset")
        JsMockito.verify(mockOnSourceUpdatedHandler3)()
      )
    )
    suite("watch", ()->
      test("Unbinds all watched collections add events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("add", onsourceupdatedHandlerMatcher)
      )
      test("Unbinds all watched collections add events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("remove", onsourceupdatedHandlerMatcher)
      )
      test("Unbinds all watched collections add events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("reset", onsourceupdatedHandlerMatcher)
      )
      test("Empties watched collections collection", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        chai.assert.equal(bvmc.length, 0)

      )
      test("Multiple calls unbinds once", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)

      )
      test("emptyCollection flag not set - leaves collection in state prior to unwatch call", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.models = [6,4,2]
        bvmc.unwatch()
        chai.assert.deepEqual(bvmc.models, [6,4,2])

      )
      test("emptyCollection set - pops each element from collection starting at the end", ()->
        bvmc.pop= JsMockito.mockFunction()
        JsMockito.when(bvmc.pop)().then(()->bvmc.models.pop())
        bvmc.watch([coll2,coll3,coll4])
        bvmc.models = [6,4,2]
        bvmc.unwatch()
        JsMockito.verify(bvmc.pop, JsMockito.Verifiers.times(3))

      )
    )
    suite("updateFromWatchedCollection", ()->

      realCollection = null
      realCollectionThreeItems = null
      realCollectionThreeIrrelevantItems =null

      realCollectionFiveMixedItems = null
      realCollectionTwoItems = null
      realOtherCollection = null
      setup(()->
        realCollection = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollection_MOCK1"}
        ])
        realCollectionThreeItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionThreeItems_MOCK1"}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionThreeItems_MOCK2"}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionThreeItems_MOCK3"}

        ])
        realCollectionThreeIrrelevantItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionThreeIrrelevantItems_MOCK1",irrelevant:true}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionThreeIrrelevantItems_MOCK2",irrelevant:true}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionThreeIrrelevantItems_MOCK3",irrelevant:true}

        ])

        realCollectionFiveMixedItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionFiveMixedItems_MOCK1",irrelevant:true}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionFiveMixedItems_MOCK2"}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionFiveMixedItems_MOCK3",irrelevant:true}
          {id:"MOCK4",cid:"MOCK4",matchVal:"realCollectionFiveMixedItems_MOCK4"}
          {id:"MOCK5",cid:"MOCK5",matchVal:"realCollectionFiveMixedItems_MOCK5",irrelevant:true}

        ])
        realCollectionTwoItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionTwoItems_MOCK1"}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionTwoItems_MOCK2"}

        ])
        realOtherCollection = new Backbone.Collection([
          {id:"MOCKOTHER1",cid:"MOCKOTHER1"}
        ])
      )
      test("watchingSingleCollectionSingleItem_createsItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollection])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 1)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollection_MOCK1")
      )
      test("watchingSingleCollectionFiveItems_createsFiveItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 5)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionFiveMixedItems_MOCK3")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionFiveMixedItems_MOCK5")
      )
      test("watchingSingleCollectionAllRelevantItems_createsAllItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionThreeItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 3)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionThreeItems_MOCK3")
      )
      test("watchingSingleCollectionAllIrrelevantItems_createsNoItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 0)
      )

      test("watchingSingleCollectionMixedItems_createsOnlyRelevantItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 2)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK4")
      )

      test("watchingMultpleCollectionsMixedItems_createsAllItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 12)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionFiveMixedItems_MOCK3")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionFiveMixedItems_MOCK5")
        chai.assert.equal(bvmc.at(5).get("match"),"realCollection_MOCK1")
        chai.assert.equal(bvmc.at(6).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(7).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(8).get("match"),"realCollectionThreeItems_MOCK3")
        chai.assert.equal(bvmc.at(9).get("match"),"realCollectionThreeIrrelevantItems_MOCK1")
        chai.assert.equal(bvmc.at(10).get("match"),"realCollectionThreeIrrelevantItems_MOCK2")
        chai.assert.equal(bvmc.at(11).get("match"),"realCollectionThreeIrrelevantItems_MOCK3")
      )
      test("watchingMultpleCollectionsMixedItems_createsAllRelevantItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 6)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollection_MOCK1")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(5).get("match"),"realCollectionThreeItems_MOCK3")
      )
      test("addingRelevantItem_addsItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollection.push({id:"MOCK2",cid:"MOCK2",matchVal:"realCollection_MOCK2"})
        bvmc.add=JsMockito.mockFunction()
        bvmc.remove=JsMockito.mockFunction()
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))

      )
      test("addingThreeRelevantItems_addsThreeItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollection.push({id:"MOCK2",cid:"MOCK2",matchVal:"realCollection_MOCK2"})
        realCollection.push({id:"MOCK3",cid:"MOCK3",matchVal:"realCollection_MOCK3"})
        realCollection.push({id:"MOCK4",cid:"MOCK4",matchVal:"realCollection_MOCK4"})
        bvmc.add=JsMockito.mockFunction()
        bvmc.remove=JsMockito.mockFunction()
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK3"))
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK4"))
      )

      test("removingRelevantItem_removesItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollectionFiveMixedItems.remove(realCollectionFiveMixedItems.at(1))
        oadd=bvmc.add
        oremove= bvmc.remove
        bvmc.add=JsMockito.mockFunction()
        JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
          oadd.call(bvmc,i)
        )
        bvmc.remove=JsMockito.mockFunction()
        JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
          oremove.call(bvmc,i)
        )
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))

      )
      test("clearingWatchedCollection_removesAllRelevantItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollectionFiveMixedItems.reset()
        oadd=bvmc.add
        oremove= bvmc.remove
        bvmc.add=JsMockito.mockFunction()
        JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
          oadd.call(bvmc,i)
        )
        bvmc.remove=JsMockito.mockFunction()
        JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
          oremove.call(bvmc,i)
        )
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
        JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK4")))

      )
    )
  )


)

