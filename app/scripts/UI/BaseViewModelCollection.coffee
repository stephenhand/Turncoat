define(["underscore", "backbone"], (_, Backbone)->
  BaseViewModelCollection=Backbone.Collection.extend(
    initialize: (options)->

    watch:(collections)->
      @watchedCollections ?= []
      for collection in collections
        if !_.contains(@watchedCollections, collection)
          collection.on("add", @onSourceUpdated)
          collection.on("remove", @onSourceUpdated)
          collection.on("reset", @onSourceUpdated)
          @watchedCollections.push(collection)

    onSourceUpdated:()=>

    updateFromWatchedCollections:(comparer, adder, watchCollectionSelector)->
      processed = []
      for watchedCollection in @watchedCollections or []
        for watchedItem in watchedCollection.models when !watchCollectionSelector? or watchCollectionSelector(watchedItem)
          VM = @find((item)->
            comparer(item, watchedItem)
            #watchedItem instanceof FleetAsset and item.get("modelId") is watchedItem.id
          )
          if !VM? then @push(adder(watchedItem)) #new FleetAsset2DViewModel(model:fleetAsset))
          processed.push(watchedItem)

      #remove surplus ships
      counter = 0
      while counter < @length
        if (!_.find(processed, (processedItem)=>comparer(@at(counter),processedItem)))
          @remove(@at(counter))
        else counter++
  )
)


