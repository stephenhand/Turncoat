define(["underscore", "backbone", "rivets"], (_, Backbone, rivets)->
    BaseView=Backbone.View.extend(
        initialize: (options)->
            if options?
                @template = options.template;
                @rootSelector = options.rootSelector;

        render:()->
            rivets.bind(@rootSelector, @model)
    )

    BaseView
)


