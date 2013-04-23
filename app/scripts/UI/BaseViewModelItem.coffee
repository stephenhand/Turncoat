define(["underscore", "backbone"], (_, Backbone)->
  BaseViewModelItem=Backbone.Model.extend(
    initialize: (options)->
    watch:(modelAttributesLists)->
      @watchedModels ?=[]
      for modelAttributes in modelAttributesLists
        @watchedModels[modelAttributes.model]?=[]
        for attribute in modelAttributes.attributes
          if !@watchedModels[modelAttributes.model][attribute]?
            modelAttributes.model.on("change:"+attribute, @onModelUpdated)
            @watchedModels[modelAttributes.model][attribute] = true
    onModelUpdated:()=>
    unwatch:()->
  )
)


