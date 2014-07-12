define(["underscore","backbone"],(_, Backbone)->
    Move = Backbone.Model.extend(
      initialize: (options)->
        @set("actions", @get("actions") ? new Backbone.Collection())




    )
    Move
)