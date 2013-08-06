define(['underscore', 'backbone', 'UI/BaseViewModelCollection', 'UI/BaseViewModelItem', 'AppState'], (_, Backbone, BackboneViewModelCollection, BackboneViewModelItem, AppState)->



  CreateGameViewModel = Backbone.Model.extend(
    initialize:()->
      @gameTypes=new BackboneViewModelCollection( )
      @gameTypes.watch(AppState.get("gameTemplates"))

      @gameTypes.onSourceUpdated=()=>
        @updateGameTemplatesList()

    updateGameTemplatesList:()->

  )


  CreateGameViewModel
)

