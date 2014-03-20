define(["underscore", "backbone"], (_, Backbone)->
  ObservingViewModelCollection=Backbone.Collection.extend(
    initialize: (options)->

    watch:(collections, attributes)->
      @watchedCollections ?= []
      modelHandler = ()=>@onSourceUpdated()

      bindModel = (model)->
        if attributes?
          model.on("change:"+attribute, modelHandler) for attribute in attributes

      unbindModel = (model)->
        if attributes?
          model.off("change:"+attribute, modelHandler) for attribute in attributes

      addHandler = (model)=>
        bindModel(model)
        @onSourceUpdated()

      removeHandler = (model)=>
        unbindModel(model)
        @onSourceUpdated()

      resetHandler = (collection)=>
        unbindModel(model) for model in collection.oldModels
        bindModel(model) for model in collection.models
        collection.oldModels = collection.models
        @onSourceUpdated()


      for collection in collections
        if !_.contains(@watchedCollections, collection)
          collection.oldModels = collection.models
          collection.on("add", addHandler)
          collection.on("remove", removeHandler)
          collection.on("reset", resetHandler)
          bindModel(model) for model in collection.models
          @watchedCollections.push(collection)

      @unwatch=(emptyCollection)=>
        for collection in @watchedCollections
          collection.off("add", addHandler)
          collection.off("remove", modelHandler)
          collection.off("reset", modelHandler)
          unbindModel(model) for model in collection.models
        @watchedCollections=[]
        if emptyCollection then (@pop() while @length)

    unwatch:()->


    onSourceUpdated:()=>

    updateFromWatchedCollections:(comparer, adder, watchCollectionSelector, onremove)->
      processed = []
      for watchedCollection in @watchedCollections or []
        for watchedItem in watchedCollection.models when !watchCollectionSelector? or watchCollectionSelector(watchedItem)
          VM = @find((item)->
            comparer(item, watchedItem)
          )
          if !VM? then @add(adder(watchedItem))
          processed.push(watchedItem)

      #remove surplus items
      counter = 0
      while counter < @length
        if (!_.find(processed, (processedItem)=>comparer(@at(counter),processedItem)))
          r = @at(counter)
          @remove(r)
          (onremove ? ()->)(r)
        else counter++
  )
  ObservingViewModelCollection
)


