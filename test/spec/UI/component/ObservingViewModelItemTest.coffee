define(['isolate!UI/component/ObservingViewModelItem','backbone'], (ObservingViewModelItem, Backbone)->
  suite("ObservingViewModelItem", ()->
    mockWatchDataSingleAttribute = [
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["A"]
    ]
    mockWatchDataMultiAttribute = [
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["A","B","C"]
    ]
    mockWatchDataMultiModel = [
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["A","B","C"]
    ,
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["D"]
    ,
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["E","F"]
    ]
    mockWatchDataDupAttribute = [
      model:
        on:JsMockito.mockFunction()
        off:JsMockito.mockFunction()
      attributes:["A","A"]

    ]
    mockWatchDataRealEvent = [
      model: _.extend({},Backbone.Events)
      attributes:["A","A"]

    ]


    suite("watch", ()->
      test("bindsUpdateFromModelToSingleAttributeChangeOnCorrectModel", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.watch(mockWatchDataSingleAttribute)
        JsMockito.verify(mockWatchDataSingleAttribute[0].model.on)("change:A",JsHamcrest.Matchers.func())
      )
      test("bindsUpdateFromModelToMultipleAttributeChangeOnCorrectModel", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.watch(mockWatchDataMultiAttribute)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:A",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:B",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:C",JsHamcrest.Matchers.func())
      )
      test("bindsUpdateFromModelToMultipleModelChangeOnCorrectModel", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.watch(mockWatchDataMultiModel)
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:A",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:B",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:C",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[1].model.on)("change:D",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:E",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:F",JsHamcrest.Matchers.func())
      )
      test("doesNotDupBinds", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.watch(mockWatchDataDupAttribute)
        JsMockito.verify(mockWatchDataDupAttribute[0].model.on, JsMockito.Verifiers.once())("change:A",JsHamcrest.Matchers.func())
      )
    )
    suite("watchedEvent",()->
      test("watchedObjectTriggersOnModelUpdatedWhenWatchedAttributeChanged", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.onModelUpdated = JsMockito.mockFunction()
        bvmi.watch(mockWatchDataRealEvent)
        mockWatchDataRealEvent[0].model.trigger("change:A")
        JsMockito.verify(bvmi.onModelUpdated)(mockWatchDataRealEvent[0].model)
      )
      test("watchedObjectNeverTriggersOnModelUpdatedWhenOtherAttributeChanged", ()->
        bvmi = new ObservingViewModelItem()
        bvmi.onModelUpdated = JsMockito.mockFunction()
        bvmi.watch(mockWatchDataRealEvent)
        mockWatchDataRealEvent[0].model.trigger("change:B")
        JsMockito.verify(bvmi.onModelUpdated, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
      )
    )
    suite("unwatch",()->
      ovmi = undefined
      setup(()->

        ovmi = new ObservingViewModelItem()
      )
      suite("Watching single attribute on single model", ()->
        handler = undefined
        setup(()->
          JsMockito.when(mockWatchDataSingleAttribute[0].model.on)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything()).then((e, h)->
            handler = h
          )
          ovmi.watch(mockWatchDataSingleAttribute)
        )
        test("Removes 'change:xxx' event handlers from watched model that was bound on watch for attribute", ()->
          ovmi.unwatch()
          JsMockito.verify(mockWatchDataSingleAttribute[0].model.off)("change:A", handler)
        )
        test("Multiple calls - removes 'change:xxx' event handlers only once", ()->
          ovmi.unwatch()
          ovmi.unwatch()
          ovmi.unwatch()
          ovmi.unwatch()
          ovmi.unwatch()
          JsMockito.verify(mockWatchDataSingleAttribute[0].model.off)("change:A", handler)
        )
      )
      test("Watching several attributes on single model - Removes 'change:xxx' event handlers from watched model that were bound on watch for all attributes", ()->
        handler1 = undefined
        handler2 = undefined
        handler3 = undefined
        JsMockito.when(mockWatchDataMultiAttribute[0].model.on)("change:A", JsHamcrest.Matchers.anything()).then((e, h)->
          handler1 = h
        )
        JsMockito.when(mockWatchDataMultiAttribute[0].model.on)("change:B", JsHamcrest.Matchers.anything()).then((e, h)->
          handler2 = h
        )
        JsMockito.when(mockWatchDataMultiAttribute[0].model.on)("change:C", JsHamcrest.Matchers.anything()).then((e, h)->
          handler3 = h
        )
        ovmi.watch(mockWatchDataMultiAttribute)
        ovmi.unwatch()
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.off)("change:A", handler1)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.off)("change:B", handler2)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.off)("change:C", handler3)
      )
      test("Watching several attributes on several models model - Removes 'change:xxx' event handlers from all on all", ()->
        handler1 = undefined
        handler2 = undefined
        handler3 = undefined
        handler4 = undefined
        handler5 = undefined
        handler6 = undefined
        JsMockito.when(mockWatchDataMultiModel[0].model.on)("change:A", JsHamcrest.Matchers.anything()).then((e, h)->
          handler1 = h
        )
        JsMockito.when(mockWatchDataMultiModel[0].model.on)("change:B", JsHamcrest.Matchers.anything()).then((e, h)->
          handler2 = h
        )
        JsMockito.when(mockWatchDataMultiModel[0].model.on)("change:C", JsHamcrest.Matchers.anything()).then((e, h)->
          handler3 = h
        )
        JsMockito.when(mockWatchDataMultiModel[1].model.on)("change:D", JsHamcrest.Matchers.anything()).then((e, h)->
          handler4 = h
        )
        JsMockito.when(mockWatchDataMultiModel[2].model.on)("change:E", JsHamcrest.Matchers.anything()).then((e, h)->
          handler5 = h
        )
        JsMockito.when(mockWatchDataMultiModel[2].model.on)("change:F", JsHamcrest.Matchers.anything()).then((e, h)->
          handler6 = h
        )
        ovmi.watch(mockWatchDataMultiModel)
        ovmi.unwatch()
        JsMockito.verify(mockWatchDataMultiModel[0].model.off)("change:A", handler1)
        JsMockito.verify(mockWatchDataMultiModel[0].model.off)("change:B", handler2)
        JsMockito.verify(mockWatchDataMultiModel[0].model.off)("change:C", handler3)
        JsMockito.verify(mockWatchDataMultiModel[1].model.off)("change:D", handler4)
        JsMockito.verify(mockWatchDataMultiModel[2].model.off)("change:E", handler5)
        JsMockito.verify(mockWatchDataMultiModel[2].model.off)("change:F", handler6)
      )
      test("Does not attempt to repeatedly upbind when dups occur in original watch", ()->
        handler1 = undefined
        JsMockito.when(mockWatchDataDupAttribute[0].model.on)("change:A", JsHamcrest.Matchers.anything()).then((e, h)->
          handler1 = h
        )
        ovmi.watch(mockWatchDataDupAttribute)
        ovmi.unwatch()
        JsMockito.verify(mockWatchDataDupAttribute[0].model.off)("change:A", handler1)
      )

    )
  )


)

