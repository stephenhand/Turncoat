define(["underscore", "backbone"], (_, Backbone)->
    Game=Backbone.Model.extend(
        initialize: (options)->

        loadState:(state)->
            @state = state


    )

    Game
)


