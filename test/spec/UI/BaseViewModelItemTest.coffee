define(['isolate!UI/BaseViewModelItem','backbone'], (BaseViewModelItem, Backbone)->
  suite("BaseViewModelItem", ()->
    mockWatchDataSingleAttribute = [
      model:
        on:JsMockito.mockFunction()
      attributes:["A"]
    ]
    mockWatchDataMultiAttribute = [
      model:
        on:JsMockito.mockFunction()
      attributes:["A","B","C"]
    ]
    mockWatchDataMultiModel = [
      model:
        on:JsMockito.mockFunction()
      attributes:["A","B","C"]
    ,
      model:
        on:JsMockito.mockFunction()
      attributes:["D"]
    ,
      model:
        on:JsMockito.mockFunction()
      attributes:["E","F"]
    ]
    mockWatchDataDupAttribute = [
      model:
        on:JsMockito.mockFunction()
      attributes:["A","A"]

    ]
    mockWatchDataRealEvent = [
      model: _.extend({},Backbone.Events)
      attributes:["A","A"]

    ]


    suite("watch", ()->
      test("bindsUpdateFromModelToSingleAttributeChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataSingleAttribute)
        JsMockito.verify(mockWatchDataSingleAttribute[0].model.on)("change:A",JsHamcrest.Matchers.func())
      )
      test("bindsUpdateFromModelToMultipleAttributeChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataMultiAttribute)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:A",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:B",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:C",JsHamcrest.Matchers.func())
      )
      test("bindsUpdateFromModelToMultipleModelChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataMultiModel)
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:A",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:B",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:C",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[1].model.on)("change:D",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:E",JsHamcrest.Matchers.func())
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:F",JsHamcrest.Matchers.func())
      )
      test("doesNotDupBinds", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataDupAttribute)
        JsMockito.verify(mockWatchDataDupAttribute[0].model.on, JsMockito.Verifiers.once())("change:A",JsHamcrest.Matchers.func())
      )
    )
    suite("watchedEvent",()->
      test("watchedObjectTriggersOnModelUpdatedWhenWatchedAttributeChanged", ()->
        bvmi = new BaseViewModelItem()
        bvmi.onModelUpdated = JsMockito.mockFunction()
        bvmi.watch(mockWatchDataRealEvent)
        mockWatchDataRealEvent[0].model.trigger("change:A")
        JsMockito.verify(bvmi.onModelUpdated)(mockWatchDataRealEvent[0].model)
      )
      test("watchedObjectNeverTriggersOnModelUpdatedWhenOtherAttributeChanged", ()->
        bvmi = new BaseViewModelItem()
        bvmi.onModelUpdated = JsMockito.mockFunction()
        bvmi.watch(mockWatchDataRealEvent)
        mockWatchDataRealEvent[0].model.trigger("change:B")
        JsMockito.verify(bvmi.onModelUpdated, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
      )
    )
  )


)

