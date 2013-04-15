define(['isolate!UI/ManOWarTableTopView'], (ManOWarTableTopView)->

  mocks = window.mockLibrary["UI/ManOWarTableTopView"];
  suite("ManOWarTableTopView", ()->
    suite("constructor", ()->
      test("constructsPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.playAreaView.mockId)
      )
    )
  )

)

