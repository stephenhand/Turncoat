define(["underscore", "backbone"], (_, Backbone)->
  ObservingViewModelCollection=Backbone.Collection.extend(
    initialize: (options)->

    watch:(collections)->
      @watchedCollections ?= []
      wrappedHandler = ()=>@onSourceUpdated()
      for collection in collections
        if !_.contains(@watchedCollections, collection)
          collection.on("add", wrappedHandler)
          collection.on("remove", wrappedHandler)
          collection.on("reset", wrappedHandler)
          @watchedCollections.push(collection)
      @unwatch=(emptyCollection)=>
        for collection in @watchedCollections
          collection.off("add", wrappedHandler)
          collection.off("remove", wrappedHandler)
          collection.off("reset", wrappedHandler)
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


