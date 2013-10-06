define(["underscore", "backbone"], (_, Backbone)->
  ObservingViewModelItem=Backbone.Model.extend(
    initialize: (options)->
      @set("classList", "view-model-item")
    watch:(modelAttributesLists)->
      context = @
      @watchedModels ?= []
      for modelAttributes in modelAttributesLists
        @watchedModels[modelAttributes.model]?=[]
        for attribute in modelAttributes.attributes
          if !@watchedModels[modelAttributes.model][attribute]?
            modelAttributes.model.on("change:"+attribute,
              ()->
                if context.watchedModels[@][attribute]
                  context.onModelUpdated(@)
            )
            @watchedModels[modelAttributes.model][attribute] = true
    unwatch:()->
    onModelUpdated:(model)=>
  )
  ObservingViewModelItem
)


