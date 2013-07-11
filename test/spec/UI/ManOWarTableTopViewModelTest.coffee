define(['isolate!UI/ManOWarTableTopViewModel', 'app'], (ManOWarTableTopViewModel, app)->
  suite("ManOWarTableTopViewModel", ()->
    suite("initialize", ()->
      test("bindsAdministrationDialogueActiveToGameDataRequiredAppEvent", ()->
        MOWTTVM = new ManOWarTableTopViewModel()
        app.trigger("gameDataRequired")
        chai.assert.equal(MOWTTVM.get("administrationDialogueActive"), true)
      )
    )
  )


)

