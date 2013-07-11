define(["underscore", "backbone","App"], (_, Backbone, App)->
  ManOWarTableTopViewModel=Backbone.Model.extend(
    initialize: (options)->
      App.on("gameDataRequired",()=>
        @set("administrationDialogueActive", true)
      )
  )

  ManOWarTableTopViewModel
)


