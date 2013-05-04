define(['underscore', 'backbone', 'UI/BaseView', 'UI/BaseViewModelCollection', 'text!templates/PlayArea.html'], (_, Backbone, BaseView, BaseViewModelCollection, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)
    createModel:()->
      ships = new BaseViewModelCollection()
      ships.watch(@gameState.searchChildren((item)->
          item instanceOf(Backbone.Collection) && _.find(item,(collItem)->
            collItem instanceof FleetAsset
          )
        )
      )
      @model =
        ships:{}
  PlayAreaView
)

