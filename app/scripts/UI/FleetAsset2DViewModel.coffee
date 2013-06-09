define(['underscore', 'backbone', 'UI/BaseViewModelItem'], (_, Backbone, BaseViewModelItem)->
  class FleetAsset2DViewModel extends BaseViewModelItem
    initialize:(options)->
      if (options?.model?)
        @watch([
          model:options.model
          attributes:[
            "position"
          ]
        ,
          model:options.model.position
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        ])
        @set("modelId", options.model.id)

    updateFromFleetAsset:()->

    onModelUpdated:()=>
      updateFromFleetAsset(@)

  FleetAsset2DViewModel
)

