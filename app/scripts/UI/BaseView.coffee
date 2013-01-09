define(["Underscore", "Backbone"], (Underscore, Backbone)->
    BaseView=Backbone.View.extend(
        initialize: (options)->
            if options?
                @template = options.template;
                @rootSelector = options.rootSelector;

        render:()->

    )


)


