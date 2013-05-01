define(['underscore', 'backbone', 'UI/BaseViewModelItem'], (_, Backbone, BaseViewModelItem)->
  class FleetAsset2DViewModel extends BaseViewModelItem
    initialize:(options)->
      if (options.model?)
        @watch([
          model:options.model
          attributes:[
            "position"
          ]
        ])

  FleetAsset2DViewModel
)

