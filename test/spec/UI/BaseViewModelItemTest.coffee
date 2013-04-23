define(['isolate!UI/BaseViewModelItem'], (BaseViewModelItem)->
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

    suite("watch", ()->
      test("bindsUpdateFromModelToSingleAttributeChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataSingleAttribute)
        JsMockito.verify(mockWatchDataSingleAttribute[0].model.on)("change:A",bvmi.onModelUpdated)
      )
      test("bindsUpdateFromModelToMultipleAttributeChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataMultiAttribute)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:A",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:B",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiAttribute[0].model.on)("change:C",bvmi.onModelUpdated)
      )
      test("bindsUpdateFromModelToMultipleModelChangeOnCorrectModel", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataMultiModel)
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:A",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:B",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiModel[0].model.on)("change:C",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiModel[1].model.on)("change:D",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:E",bvmi.onModelUpdated)
        JsMockito.verify(mockWatchDataMultiModel[2].model.on)("change:F",bvmi.onModelUpdated)
      )
      test("doesNotDupBinds", ()->
        bvmi = new BaseViewModelItem()
        bvmi.watch(mockWatchDataDupAttribute)
        JsMockito.verify(mockWatchDataDupAttribute[0].model.on, JsMockito.Verifiers.once())("change:A",bvmi.onModelUpdated)
      )
    )
  )


)

