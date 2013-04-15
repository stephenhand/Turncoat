define(["underscore", "backbone", "rivets"], (_, Backbone, rivets)->
    BaseView=Backbone.View.extend(
        initialize: (options)->
          if options?
            @template = options.template;
            @rootSelector = options.rootSelector;
        createModel:()->
          throw(new Error("createModel method required for BaseViews"))
        render:()->
          @view = rivets.bind(@rootSelector, @model)
    )

    BaseView
)


