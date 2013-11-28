define(["underscore", "backbone"], (_, Backbone)->
  ObservingViewModelItem=Backbone.Model.extend(
    initialize: (options)->
      @set("classList", "view-model-item")
    watch:(modelAttributesLists)->
      context = @
      @watchedModels ?= []
      for modelAttributes in modelAttributesLists
        watchedModel = _.where(@watchedModels, model:modelAttributes.model).pop()
        if !watchedModel?
          watchedModel =
            model:modelAttributes.model
          @watchedModels.push(watchedModel)
        watchedModel.attributes ?={}
        for attribute in modelAttributes.attributes
          if !watchedModel.attributes[attribute]?
            handler =  ()->
              context.onModelUpdated(modelAttributes.model, attribute)
            modelAttributes.model.on("change:"+attribute, handler)
            watchedModel.attributes[attribute] = handler
    unwatch:()->
      for modelAtt in @watchedModels
        if modelAtt.attributes
         for name, handler of modelAtt.attributes
           modelAtt.model.off("change:"+name, handler)
           delete modelAtt.attributes[name]
      @watchedModels = []
    onModelUpdated:(model, attribute)=>
  )
  ObservingViewModelItem
)


