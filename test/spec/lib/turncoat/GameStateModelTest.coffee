define(["isolate!lib/turncoat/GameStateModel", "backbone"], (GameStateModel, Backbone)->
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


      gsmWithGSMChildrenOfBackboneCollections = new GameStateModel()
      gsmWithGSMChildrenOfBackboneCollections.attributes = {
        a:new GameStateModel()
        b:new GameStateModel()
      }
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.val = 8
      gsmWithGSMChildrenOfBackboneCollections.attributes.b.val = 7
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes =
        c:new GameStateModel()
        d:new GameStateModel()
        dd:
          dda:new GameStateModel()
          ddb:new GameStateModel()
        e:new GameStateModel()
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.val = 9
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.d.val = 10
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.dd.val = 11
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.dd.dda.val = 111
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.dd.ddb.val = 111
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.e.val = 12
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.attributes =
        f:new GameStateModel()
        g:new Backbone.Collection([
          new Backbone.Model()
          new GameStateModel()
          {val:142}
          new GameStateModel()
        ])
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.attributes.f.val = 13
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.attributes.g.at(0).val = 140
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.attributes.g.at(1).val = 141
      gsmWithGSMChildrenOfBackboneCollections.attributes.a.attributes.c.attributes.g.at(3).val = 143

      gsmWithNestedCollections = new GameStateModel()
      gsmWithNestedCollections.attributes = {
        a:new GameStateModel()
        b:new Backbone.Collection([
          new Backbone.Model(
            bb:new Backbone.Collection([
              new GameStateModel()
              new Backbone.Model()
            ])
            bc:{val:14}
          )
          new Backbone.Model()
          new GameStateModel()
        ])
        c:new Backbone.Model()
      }

      gsmWithNestedCollections.attributes.a.val = 5
      gsmWithNestedCollections.attributes.b.val = 6
      gsmWithNestedCollections.attributes.c.val = 7
      gsmWithNestedCollections.attributes.b.at(0).val = 8
      gsmWithNestedCollections.attributes.b.at(1).val = 9
      gsmWithNestedCollections.attributes.b.at(2).val = 10
      gsmWithNestedCollections.attributes.b.at(0).attributes.bb.val = 11
      gsmWithNestedCollections.attributes.b.at(0).attributes.bb.at(0).val = 12
      gsmWithNestedCollections.attributes.b.at(0).attributes.bb.at(1).val = 13

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

      test("deepExplicitFalseSetAsFirstParam_doesntFindGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren(false)
        chai.assert.equal(res.length, 2)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
      )

      test("deepExplicitFalseSetAsSecondParam_doesntFindGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren((model)->
          true
        , false)
        chai.assert.equal(res.length, 2)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
      )

      test("deepExplicitTrueSetAsFirstParam_doesFindGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren(true)
        chai.assert.equal(res.length, 6)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
      )

      test("deepExplicitTrueSetAsSecondParam_doesFindGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren((model)->
          true
        , true)
        chai.assert.equal(res.length, 6)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
      )

      test("modelCheckerSetAsOnlyParam_findsAndChecksGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren((model)->
          model.val%2 is 1
        )
        chai.assert.equal(res.length, 3)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 13)
      )

      test("modelCheckerSetWithExplicitDeepTrue_findsAndChecksGameStateModelsRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren((model)->
          model.val%2 is 1
        , true
        )
        chai.assert.equal(res.length, 3)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 13)
      )

      test("modelCheckerSetWithExplicitDeepFalse_findsAndChecksGameStateModelsNonRecursively", ()->
        res = gsmWith3LevelSubGSms.searchChildren((model)->
          model.val%2 is 1
        , false
        )
        chai.assert.equal(res.length, 1)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 7)
      )


      test("noSearchFuncSet_findsModelsInBackboneCollections", ()->
        res = gsmWithGSMChildrenOfBackboneCollections.searchChildren()
        chai.assert.equal(res.length, 11)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
        chai.assert.include(resVals, 140)
        chai.assert.include(resVals, 141)
        chai.assert.include(resVals, 143)
      )

      test("noSearchFuncSet_findsModelsInNestedBackboneCollections", ()->
        res = gsmWithNestedCollections.searchChildren()
        chai.assert.equal(res.length, 9)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 5)
        chai.assert.include(resVals, 6)
        chai.assert.include(resVals, 7)
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 9)
        chai.assert.include(resVals, 10)
        chai.assert.include(resVals, 11)
        chai.assert.include(resVals, 12)
        chai.assert.include(resVals, 13)
      )

      test("collectionsOnlySearchFunc_findsCollectionsInNestedBackboneCollections", ()->
        res = gsmWithNestedCollections.searchChildren((item)->
          item instanceof Backbone.Collection
        )
        chai.assert.equal(res.length, 2)
        resVals = thisRes.val for thisRes in res
        chai.assert.include(resVals, 8)
        chai.assert.include(resVals, 11)
      )

      suite("searchGameStateModels", ()->
        test("noSearchFuncSet_findsOnlyGSMsInBackboneCollections", ()->
          res = gsmWithGSMChildrenOfBackboneCollections.searchGameStateModels()
          chai.assert.equal(res.length, 8)
          resVals = thisRes.val for thisRes in res
          chai.assert.include(resVals, 8)
          chai.assert.include(resVals, 7)
          chai.assert.include(resVals, 9)
          chai.assert.include(resVals, 10)
          chai.assert.include(resVals, 12)
          chai.assert.include(resVals, 13)
          chai.assert.include(resVals, 140)
          chai.assert.include(resVals, 143)
        )
      )
    )
    suite("getOwnershipChain", ()->
      gsmImmediateChild = new GameStateModel()
      gsmImmediateChild.attributes = {
        child:new GameStateModel()
      }

      gsmChildTwoLevelsDeep = new GameStateModel()
      gsmChildTwoLevelsDeep.attributes = {
        child:new Backbone.Model()
      }
      gsmChildTwoLevelsDeep.get("child").set("child", new GameStateModel())


      gsmChildThreeLevelsDeep = new GameStateModel()
      gsmChildThreeLevelsDeep.attributes = {
        child:new Backbone.Model()
      }
      gsmChildThreeLevelsDeep.get("child").set("child", new Backbone.Collection([
        new GameStateModel()
      ]))

      test("directChildSpecified_getsRootAndOwner", ()->
        res = gsmImmediateChild.attributes.child.getOwnershipChain(gsmImmediateChild)
        chai.assert.equal(res.length, 2)
        chai.assert.equal(res[0], gsmImmediateChild.get("child"))
        chai.assert.equal(res[1], gsmImmediateChild)

      )

      test("twoLevelChildSpecified_getsRootIntermediateLevelAndOwner", ()->
        res = gsmChildTwoLevelsDeep.get("child").get("child").getOwnershipChain(gsmChildTwoLevelsDeep)
        chai.assert.equal(res.length, 3)
        chai.assert.equal(res[0], gsmChildTwoLevelsDeep.get("child").get("child"))
        chai.assert.equal(res[1], gsmChildTwoLevelsDeep.get("child"))
        chai.assert.equal(res[2], gsmChildTwoLevelsDeep)

      )

      test("threeLevelChildWithCollectionSpecified_getsRootIntermediateLevelsAndOwner", ()->
        res = gsmChildThreeLevelsDeep.get("child").get("child").at(0).getOwnershipChain(gsmChildThreeLevelsDeep)
        chai.assert.equal(res.length, 4)
        chai.assert.equal(res[0], gsmChildThreeLevelsDeep.get("child").get("child").at(0))
        chai.assert.equal(res[1], gsmChildThreeLevelsDeep.get("child").get("child"))
        chai.assert.equal(res[2], gsmChildThreeLevelsDeep.get("child"))
        chai.assert.equal(res[3], gsmChildThreeLevelsDeep)
      )
    )
  )


)