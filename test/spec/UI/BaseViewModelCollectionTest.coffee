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
  )


)

