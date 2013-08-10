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

      @selectedGameType = new Backbone.Model(
      )
      @selectedGameType.on("change:id", ()->
        @set("template",AppState.loadGameTemplate(@get("id")))
        console.log("selected set")
      )
      @selectedGameType.set("id",@gameTypes.at(0)?.get("id"))

      @gameSetupTypes=new BackboneViewModelCollection( )
      @gameSetupTypes.watch([AppState.get("gameTypes")])

      @gameSetupTypes.onSourceUpdated=()=>
        @gameSetupTypes.updateFromWatchedCollections(
          (item , watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
          (watched)->
            new Backbone.Model(watched.attributes)
        )

      @gameSetupTypes.onSourceUpdated()

      @selectedGameSetupType = new Backbone.Model( )
      @selectedGameSetupType.on("change:id", ()=>
        @set("template",@gameSetupTypes.find(
          (item)=>
            item.get("id") is @selectedGameSetupType.get("id")
        ))
      )
      @selectedGameSetupType.set("id", @gameSetupTypes.at(0)?.get("id"))

  )


  CreateGameViewModel
)

