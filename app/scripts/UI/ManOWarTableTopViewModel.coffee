define(["underscore", "exports", "backbone","AppState"], (_, require, Backbone, AppState)->
  ManOWarTableTopViewModel=Backbone.Model.extend(
    initialize: (options)->
      AppState.on("gameDataRequired",()=>
        @set("administrationDialogueActive", true)
      )
  )

  ManOWarTableTopViewModel
)


