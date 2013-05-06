define(['underscore', 'backbone', 'UI/BaseView', 'UI/BaseViewModelCollection', 'UI/FleetAsset2DViewModel', 'state/FleetAsset', 'text!templates/PlayArea.html'], (_, Backbone, BaseView, BaseViewModelCollection, FleetAsset2DViewModel, FleetAsset, templateText)->
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
        ships:ships
      @updateShipsModel()
      @model.ships.onSourceUpdated = ()=>
        @updateShipsModel()

    updateShipsModel:()->
      processedShips = []
      for watchedCollection in @model.ships?.watchedCollections or []
        for fleetAsset, watchedCollectionCounter in watchedCollection.models when fleetAsset instanceof FleetAsset
          VM = @model.ships.find((ship)->
            ship.get("uuid") is fleetAsset.get("uuid")
          )
          if !VM? then @model.ships.push(new FleetAsset2DViewModel(model:fleetAsset))
          processedShips.push(fleetAsset.get("uuid"))

      #remove surplus ships
      processedCounter = 0
      shipCounter = 0
      while shipCounter < @model.ships.length
        if (processedCounter >= processedShips.length || processedShips[processedCounter] != @model.ships.at(shipCounter).get("uuid"))
          @model.ships.remove(@model.ships.at(shipCounter))
        else shipCounter++
        processedCounter++



  PlayAreaView
)

