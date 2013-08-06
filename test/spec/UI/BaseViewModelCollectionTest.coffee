define(['isolate!UI/BaseViewModelCollection'], (BaseViewModelCollection)->
  suite("BaseViewModelCollection", ()->

    suite("watch", ()->
      coll1 = coll2 = coll3 = coll4 = coll5 = null
      setup(()->
        coll1 =
          on:JsMockito.mockFunction()
        coll2 =
          on:JsMockito.mockFunction()
        coll3 =
          on:JsMockito.mockFunction()
        coll4 =
          on:JsMockito.mockFunction()
        coll5 =
          on:JsMockito.mockFunction()
      )
      test("singleCollection_BindsOnSourceUpdatedToCollectionAddEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("add", bvmc.onSourceUpdated)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionAddEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("add", bvmc.onSourceUpdated)
        JsMockito.verify(coll3.on)("add", bvmc.onSourceUpdated)
        JsMockito.verify(coll4.on)("add", bvmc.onSourceUpdated)
      )

      test("singleCollection_BindsOnSourceUpdatedToCollectionRemoveEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("remove", bvmc.onSourceUpdated)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionRemoveEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("remove", bvmc.onSourceUpdated)
        JsMockito.verify(coll3.on)("remove", bvmc.onSourceUpdated)
        JsMockito.verify(coll4.on)("remove", bvmc.onSourceUpdated)
      )

      test("singleCollection_BindsOnSourceUpdatedToCollectionResetEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on)("reset", bvmc.onSourceUpdated)
      )
      test("multipleCollections_BindsOnSourceUpdatedToCollectionResetEvent", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on)("reset", bvmc.onSourceUpdated)
        JsMockito.verify(coll3.on)("reset", bvmc.onSourceUpdated)
        JsMockito.verify(coll4.on)("reset", bvmc.onSourceUpdated)
      )

      test("singleCollection_DoesntDupBinds", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll1])
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on, JsMockito.Verifiers.once())("reset", bvmc.onSourceUpdated)
      )
      test("multipleCollections_DoesntDupBinds", ()->
        bvmc = new BaseViewModelCollection()
        bvmc.watch([coll2,coll3,coll4])
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on, JsMockito.Verifiers.once())("reset", bvmc.onSourceUpdated)
        JsMockito.verify(coll3.on, JsMockito.Verifiers.once())("reset", bvmc.onSourceUpdated)
        JsMockito.verify(coll4.on, JsMockito.Verifiers.once())("reset", bvmc.onSourceUpdated)
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
        bvmc = new BaseViewModelCollection()
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
      test("addingRelevantItem_pushesItem", ()->
        bvmc = new BaseViewModelCollection()
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
        bvmc.push=JsMockito.mockFunction()
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
        JsMockito.verify(bvmc.push)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))

      )
      test("addingThreeRelevantItems_pushesThreeItem", ()->
        bvmc = new BaseViewModelCollection()
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
        bvmc.push=JsMockito.mockFunction()
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
        JsMockito.verify(bvmc.push)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))
        JsMockito.verify(bvmc.push)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK3"))
        JsMockito.verify(bvmc.push)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK4"))
      )

      test("removingRelevantItem_removesItem", ()->
        bvmc = new BaseViewModelCollection()
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
        opush=bvmc.push
        oremove= bvmc.remove
        bvmc.push=JsMockito.mockFunction()
        JsMockito.when(bvmc.push)(JsHamcrest.Matchers.anything()).then((i)->
          opush.call(bvmc,i)
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
        bvmc = new BaseViewModelCollection()
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
        opush=bvmc.push
        oremove= bvmc.remove
        bvmc.push=JsMockito.mockFunction()
        JsMockito.when(bvmc.push)(JsHamcrest.Matchers.anything()).then((i)->
          opush.call(bvmc,i)
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

