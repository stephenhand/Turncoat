define(["underscore", "backbone", "rivets", "jquery"], (_, Backbone, rivets, $)->
    BaseView=Backbone.View.extend(
      initialize: (options)->
        if options?
          @template = options.template
          @rootSelector = options.rootSelector
          @gameState = options.gameState
          @rootContext = (options?.context)
      createModel:()->
        throw(new Error("createModel method required for BaseViews"))

      subViews:new Backbone.Model()

      routeChanged:(route)->
        view.routeChanged(route) for name, view of @subViews.attributes when view instanceof BaseView

      render:()->
        @undelegateEvents()
        @createModel()
        @$el = $(@rootSelector, @rootContext)
        @$el.html(@template)
        @view = rivets.bind(@$el.children().first(), @model)
        @delegateEvents(@events)
    )

    BaseView
)


