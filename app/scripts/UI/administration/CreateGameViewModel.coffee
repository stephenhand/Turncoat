define(['underscore', 'backbone', 'sprintf', 'UI/BaseViewModelCollection', 'UI/BaseViewModelItem', 'AppState'], (_, Backbone, sprintf, BackboneViewModelCollection, BackboneViewModelItem, AppState)->



  CreateGameViewModel = Backbone.Model.extend(
    initialize:()->
      @gameTypes=new BackboneViewModelCollection( )
      @gameTypes.watch([AppState.get("gameTemplates")])

      @gameTypes.onSourceUpdated=()=>
        @gameTypes.updateFromWatchedCollections(
          (item , watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
          (watched)->
            new Backbone.Model(
              id:watched.get("id")
              label:sprintf("%s (%s players)", watched.get("label"), watched.get("players"))
              players:watched.get("players")
            )
        )

      @gameTypes.onSourceUpdated()
  )


  CreateGameViewModel
)

