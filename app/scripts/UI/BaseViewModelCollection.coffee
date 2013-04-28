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
  )
)


