define(['isolate!UI/ManOWarTableTopViewModel', 'AppState'], (ManOWarTableTopViewModel, AppState)->
  suite("ManOWarTableTopViewModel", ()->
    suite("initialize", ()->
      test("bindsAdministrationDialogueActiveToGameDataRequiredAppEvent", ()->
        MOWTTVM = new ManOWarTableTopViewModel()
        AppState.trigger("gameDataRequired")
        chai.assert.equal(MOWTTVM.get("administrationDialogueActive"), true)
      )
    )
  )


)

