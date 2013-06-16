define(["underscore", "backbone", "rivets", "jquery", "vendor/jqModal"], (_, Backbone, rivets, $)->
    BaseView=Backbone.View.extend(
      initialize: (options)->
        if options?
          @template = options.template
          @rootSelector = options.rootSelector
          @gameState = options.gameState
          @rootContext = (options?.context)
      createModel:()->
        throw(new Error("createModel method required for BaseViews"))
      render:()->
        @createModel()
        rootJQ = $(@rootSelector, @rootContext)
        rootJQ.html(@template)
        @view = rivets.bind(rootJQ, @model)
    )

    BaseView
)


