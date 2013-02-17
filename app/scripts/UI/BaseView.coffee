define(["underscore", "backbone"], (_, Backbone)->
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


