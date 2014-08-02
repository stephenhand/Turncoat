define(['underscore', 'backbone', 'crypto', 'AppState', 'UI/component/ObservingViewModelItem'], (_, Backbone, Crypto, AppState, ObservingViewModelItem)->
  class FleetAsset2DViewModel extends ObservingViewModelItem
    initialize:(m, options)->
      super(m, options)
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
        @set("UUID", Crypto.MD5(options.model.id))
        @set("classList", @get("classList")+" fleet-asset-2d")
        dim = options.model.get("dimensions")
        @set("length", dim.get("length"))
        @set("width", dim.get("width"))
        @updateFromFleetAsset(options.model)


    updateFromFleetAsset:(model)->
      pos = model.get("position")
      @set("xpx",pos.get("x"))
      @set("ypx",pos.get("y"))
      @set("transformDegrees",pos.get("bearing"))
      @calculateClosestMoveAction=(x, y)->




    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset(model)


  FleetAsset2DViewModel
)

