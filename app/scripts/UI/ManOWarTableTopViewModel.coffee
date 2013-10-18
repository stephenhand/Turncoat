define(["underscore", "backbone", "UI/routing/Router","AppState"], (_, Backbone, Router, AppState)->
  ManOWarTableTopViewModel=Backbone.Model.extend(
    initialize: (options)->
      AppState.on("gameDataRequired",()=>
        @set("administrationDialogueActive", true)
      )
  )

  ManOWarTableTopViewModel
)


