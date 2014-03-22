define(['underscore', 'backbone', 'AppState', 'UI/component/ObservingViewModelItem'], (_, Backbone, AppState, ObservingViewModelItem)->
  class FleetAsset2DViewModel extends ObservingViewModelItem
    initialize:(options)->
      super(options)
      if (options?.model?)
        @watch([
          model:options.model
          attributes:[
            "position"
          ]
        ,
          model:options.model.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        ])
        @set("modelId", options.model.id)
        @set("classList", @get("classList")+" fleet-asset-2d")
        @updateFromFleetAsset(options.model)


    updateFromFleetAsset:(model)->
      pos = model.get("position")
      @set("xpx",pos.get("x")+"px")
      @set("ypx",pos.get("y")+"px")
      @set("transformDegrees",pos.get("bearing"))

    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset(model)


  FleetAsset2DViewModel
)

