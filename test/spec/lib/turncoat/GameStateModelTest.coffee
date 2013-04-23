define(["isolate!lib/turncoat/GameStateModel"], (GameStateModel)->
  #GameStateModelTest.coffee test file    
  suite("GameStateModelTest", ()->
    mockMarshaller ={}
    setup(()->
      mockMarshaller =
        unmarshalState:JsMockito.mockFunction()
        marshalState:JsMockito.mockFunction()
    )
    suite("fromString", ()->
      test("callsMarshallersUnmarshalState", ()->

        GameStateModel.marshaller = mockMarshaller
        GameStateModel.fromString("MOCK_MARSHALLED_OBJECT")
        JsMockito.verify(mockMarshaller.unmarshalState)("MOCK_MARSHALLED_OBJECT")
      )
      test("throwsWithNoMarshallerSet", ()->
        GameStateModel.marshaller = null
        chai.assert.throws(()->
          GameStateModel.fromString("MOCK_MARSHALLED_OBJECT")
        )
      )
    )
    suite("toString", ()->
      test("callsMarshallersMarshalState", ()->
        GameStateModel.marshaller = mockMarshaller
        gsm = new GameStateModel()
        gsm.toString()
        JsMockito.verify(mockMarshaller.marshalState)(gsm)
      )
      test("setsDefaultMarshallerWithNoMarshallerSet", ()->
        GameStateModel.marshaller = null
        gsm = new GameStateModel()
        #verify(window.mockLibrary["lib/GameStateModel"]["lib/Factory"].buildStateMarshaller)()
        res = gsm.toString()
        JsMockito.verify(GameStateModel.marshaller.marshalState)(gsm)
        chai.assert.equal(res, "MOCK_MARSHALLER_OUTPUT")
      )
    )
  )


)