define(["isolate!lib/turncoat/GameStateModel"], (GameStateModel)->
  #GameStateModelTest.coffee test file    
  suite("GameStateModelTest", ()->
    mockMarshaller ={}
    setup(()->
      mockMarshaller =
        unmarshalState:JsMockito.mockFunction()
        marshalState:JsMockito.mockFunction()
    )
    suite("constructor", ()->
      test("generatesValidUuidIfNotSupplied", ()->
        gsm = new GameStateModel()
        chai.assert.isString(gsm.get("uuid"))
        chai.assert.isTrue(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[ab89][a-f0-9]{3}-[a-f0-9]{12}/i.test(gsm.get("uuid")))
      )
      test("doesntOverwriteSuppliedUUIDEvenIfNonCompliant", ()->
        gsm = new GameStateModel(uuid:"MOCK_NON_COMPLIANT_UUID")
        chai.assert.equal(gsm.get("uuid"), "MOCK_NON_COMPLIANT_UUID")
      )
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
    suite("searchChildren", ()->
      gsmWith1LevelSubGSms = new GameStateModel()
      gsmWith1LevelSubGSms.attributes =
        a:new GameStateModel()
        b:new GameStateModel()

      gsmWith1LevelSubGSms.attributes.a.val = 8
      gsmWith1LevelSubGSms.attributes.b.val = 7

      gsmWith3LevelSubGSms = new GameStateModel()
      gsmWith3LevelSubGSms.attributes = {
        a:new GameStateModel()
        b:new GameStateModel()
      }
      gsmWith3LevelSubGSms.attributes.a.val = 8
      gsmWith3LevelSubGSms.attributes.b.val = 7
      gsmWith3LevelSubGSms.attributes.a.attributes =
        c:new GameStateModel()
        d:new GameStateModel()
        dd:{}
        e:new GameStateModel()
      gsmWith3LevelSubGSms.attributes.a.attributes.c.val = 9
      gsmWith3LevelSubGSms.attributes.a.attributes.d.val = 10
      gsmWith3LevelSubGSms.attributes.a.attributes.dd.val = 11
      gsmWith3LevelSubGSms.attributes.a.attributes.e.val = 12
      gsmWith3LevelSubGSms.attributes.a.attributes.c.attributes =
        f:new GameStateModel()
      gsmWith3LevelSubGSms.attributes.a.attributes.c.attributes.f.val = 13

      gsmWithGSMChildrenOfNoneGSMs = new GameStateModel()
      gsmWithGSMChildrenOfNoneGSMs.attributes = {
        a:new GameStateModel()
        b:new GameStateModel()
      }
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.val = 8
      gsmWithGSMChildrenOfNoneGSMs.attributes.b.val = 7
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes =
        c:new GameStateModel()
        d:new GameStateModel()
        dd:
          dda:new GameStateModel()
          ddb:new GameStateModel()

        e:new GameStateModel()
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.c.val = 9
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.d.val = 10
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.dd.val = 11
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.dd.dda.val = 111
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.dd.ddb.val = 111
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.e.val = 12
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.c.attributes =
        f:new GameStateModel()
      gsmWithGSMChildrenOfNoneGSMs.attributes.a.attributes.c.attributes.f.val = 13


      gsmWithNoSubGSMs = new GameStateModel()
      gsmWithNoSubGSMs.attributes = {
        a:{}
        b:{}
      }
      gsmWithNoSubGSMs.attributes.a.val = 8
      gsmWithNoSubGSMs.attributes.b.val = 7

      test("noSearchFuncSet_findsGameStateModelsOnAttributes", ()->
        res = gsmWith1LevelSubGSms.searchChildren()
        chai.assert.equal(res.length, 2)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
      )
      test("noSearchFuncSet_returnsEmptyArrayIfNothingToFind", ()->
        res = gsmWithNoSubGSMs.searchChildren()
        chai.assert.deepEqual(res, [])
      )


      test("noSearchFuncSet_findsGameStateModelsOnAttributesRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren()
        chai.assert.equal(res.length, 6)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
      )


      test("noSearchFuncSet_ignoresGameStateModelChildrenOfNonGSMs", ()->
        res = gsmWithGSMChildrenOfNoneGSMs.searchChildren()
        chai.assert.equal(res.length, 6)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
      )
    )
  )


)