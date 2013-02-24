define(["underscore","backbone"],(_, Backbone)->
    Move = Backbone.Collection.extend(
      initialize: (options)->

      loadState:(state)->
        @state = state



    )
    Move
)