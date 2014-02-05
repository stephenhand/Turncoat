require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("moment","lib/turncoat/GameStateModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=
        utc:JsMockito.mockFunction()
      JsMockito.when(ret.utc)().then(()->
        value:"MOCK_MOMENT_UTC:NOW"
      )
      JsMockito.when(ret.utc)(JsHamcrest.Matchers.anything()).then((input)->
        "MOCK_MOMENT_UTC:"+input
      )
      ret
    )
  )
  Isolate.mapAsFactory("uuid","lib/turncoat/GameStateModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=()->
        @func()
      ret.func = ()->
        "MOCK_UUID::"+actual()
    )
  )
)

define(["isolate!lib/turncoat/GameStateModel", "backbone", "lib/turncoat/Constants", "lib/turncoat/LogEntry", "lib/turncoat/GameHeader"], (GameStateModel, Backbone, Constants, LogEntry, GameHeader)->
  #GameStateModelTest.coffee test file    
  suite("GameStateModelTest", ()->
    mockMarshaller ={}
    mockType = Backbone.Model.extend(
      attributes:
        A:"A"
        B:"B"
        C:"C"
      mockMethod:()->
        "CHEESE"
    )
    setup(()->

      mockMarshaller =
        unmarshalState:JsMockito.mockFunction()
        marshalState:JsMockito.mockFunction()
    )
    suite("constructor", ()->
      test("generatesValidUuidIfNotSupplied", ()->
        gsm = new GameStateModel()
        chai.assert.isString(gsm.id)
        chai.assert.isTrue(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[ab89][a-f0-9]{3}-[a-f0-9]{12}/i.test(gsm.id))
      )
      test("doesntOverwriteSuppliedUUIDEvenIfNonCompliant", ()->
        gsm = new GameStateModel(id:"MOCK_NON_COMPLIANT_UUID")
        chai.assert.equal(gsm.id, "MOCK_NON_COMPLIANT_UUID")
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
    suite("getHeaderForUser", ()->
      test("returns GameHeader",()->
        gh = new GameStateModel().getHeaderForUser()
        chai.assert.instanceOf(gh,GameHeader)
      )

      test("State with id and label - copies Id and label", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection()
          players:new Backbone.Collection()
        )
        gh = gsm.getHeaderForUser("mock_user")
        chai.assert.equal(gh.get("id"), "MOCK_SAVED_ID")
        chai.assert.equal(gh.get("label"), "MOCK GAME TO SAVE")
      )
      test("State with currentUser with status - sets userStatus as matched userStatus", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_user"
            status:"MOCK_STATUS1"
          ,
            id:"mock_other_user"
            status:"MOCK_STATUS2"

          ])
        )
        chai.assert.equal(gsm.getHeaderForUser("mock_user").get("userStatus"), "MOCK_STATUS1")
      )
      test("No user specified - doesnt set user status", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_user"
            status:"MOCK_STATUS1"
          ,
            id:"mock_other_user"
            status:"MOCK_STATUS2"
          ])
        )
        chai.assert.isUndefined(gsm.getHeaderForUser().get("userStatus"))
      )
      test("State with currentUser that has no status - doesnt set user status", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_user"
          ,
            id:"mock_other_user"
            status:"MOCK_STATUS2"
          ])
        )
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("userStatus"))
      )
      test("stateWithNoPlayerAsCurrentUser_doesntSetUserStatus", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_other_user"
            status:"MOCK_STATUS2"
          ])
        )
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("userStatus"))
      )
      test("stateWithNoUserss_doesntSetUserStatus", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection()
        )
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("userStatus"))
      )
      test("stateWithSingleCreatedLogEntry_setsCreatedToTimestamp", ()->
        gsm =new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:Constants.LogEvents.GAMECREATED
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_1"}
          ,
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
          ])
        )
        chai.assert.equal("MOCK_TIME_1", gsm.getHeaderForUser("mock_user").get("created").moment)
      )
      test("stateWithMultipleCreatedLogEntries_setsCreatedToTimestampToNearestToTop", ()->
        gsm =new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_1"}
          ,
            name:Constants.LogEvents.GAMECREATED
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
          ,
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_3"}
          ,
            name:Constants.LogEvents.GAMECREATED
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_4"}
          ])
        )
        chai.assert.equal("MOCK_TIME_2", gsm.getHeaderForUser("mock_user").get("created").moment)
      )

      test("stateWithNoCreatedLogEntry_doesntSetCreated", ()->
        gsm =new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_1"}
          ,
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_2"}
          ])
        )
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("created"))
      )
      test("stateWithNoEventLog_doesntSetCreated", ()->
        gsm =new GameStateModel()
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("created"))
      )
      test("stateWithEventLog_setsLastActivityToTimestampOnTopEvent", ()->
        gsm =new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_1"}
          ,
            name:Constants.LogEvents.GAMECREATED
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
          ,
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME_3"}
          ,
            name:Constants.LogEvents.GAMECREATED
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_4"}
          ])
        )
        chai.assert.equal("MOCK_TIME_1", gsm.getHeaderForUser("mock_user").get("lastActivity").moment)
      )
      test("stateWithNoEventLog_doesntSetLastActivity", ()->
        gsm =new GameStateModel()
        chai.assert.isUndefined(gsm.getHeaderForUser("mock_user").get("lastActivity"))
      )
    )
    suite("getLatestEvent", ()->
      test("gameStateModelWithoutEventLogNoEventName_ReturnsUndefined", ()->
        gsm = new GameStateModel()
        chai.assert.isUndefined(gsm.getLatestEvent())
      )
      test("gameStateModelWithoutEventLogEventName_ReturnsUndefined", ()->
        gsm = new GameStateModel()
        chai.assert.isUndefined(gsm.getLatestEvent("EVENT_NAME"))
      )
      test("gameStateModelWithEventLogNoEventName_ReturnsTopEvent", ()->
        gsm = new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME"}
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_3"
            timestamp:{moment:"MOCK_TIME_3"}
          ])
        )
        ret= gsm.getLatestEvent()
        chai.assert.equal("MOCK_EVENT_TYPE",ret.get("name"))
        chai.assert.equal("MOCK_DETAILS",ret.get("details"))
        chai.assert.equal("MOCK_TIME",ret.get("timestamp").moment)
      )
      test("gameStateModelWithEventLogEventNameInLog_ReturnsTopEventOfThatName", ()->
        gsm = new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME"}
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_3"
            timestamp:{moment:"MOCK_TIME_3"}
          ])
        )
        ret= gsm.getLatestEvent("MOCK_EVENT_TYPE_2")
        chai.assert.equal("MOCK_EVENT_TYPE_2",ret.get("name"))
        chai.assert.equal("MOCK_DETAILS_2",ret.get("details"))
        chai.assert.equal("MOCK_TIME_2",ret.get("timestamp").moment)
      )
      test("gameStateModelWithEventLogEventNameNotInLog_ReturnsUndefined", ()->
        gsm = new GameStateModel(
          _eventLog:new Backbone.Collection([
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME"}
            counter:2
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
            counter:1
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_3"
            timestamp:{moment:"MOCK_TIME_3"}
            counter:0
          ])
        )
        chai.assert.isUndefined(gsm.getLatestEvent("MOCK_EVENT_TYPE_3"))
      )
    )
    suite("generateEvent", ()->
      gsm = null
      setup(()->
        gsm = new GameStateModel(
          _eventLog:new Backbone.Collection([
            id:"MOCK ID"
            name:"MOCK_EVENT_TYPE"
            details:"MOCK_DETAILS"
            timestamp:{moment:"MOCK_TIME"}
            counter:2
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_2"
            timestamp:{moment:"MOCK_TIME_2"}
            counter:1
          ,
            name:"MOCK_EVENT_TYPE_2"
            details:"MOCK_DETAILS_3"
            timestamp:{moment:"MOCK_TIME_3"}
            counter:0
          ])
        )
      )
      test("Creates event as LogEntry", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.instanceOf(event, LogEntry)
        chai.assert.equal(event.get("data"), "MOCK_NEW_DETAILS")
      )
      test("Uses uuid to generate id", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.match(event.get("id"), /^MOCK_UUID::.+$/)

      )
      test("Creates event with supplied data", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.equal(event.get("name"), "MOCK_NEW_EVENT")
        chai.assert.equal(event.get("data"), "MOCK_NEW_DETAILS")
      )
      test("Creates event with current utc timestamp", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.equal(event.get("timestamp").value, "MOCK_MOMENT_UTC:NOW")
      )
      test("Creates event with validation property", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.isDefined(event.get("validation"))
      )
      test("Creates event validation with counter equal to current log length", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.equal(event.get("validation").get("counter"), 3)
      )
      test("Creates event validation with previousId equal to current log's first entry ID", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.equal(event.get("validation").get("previousId"), "MOCK ID")
      )
      test("Creates event validation with previousTimestamp equal to current log's first entry timestamp", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        chai.assert.equal(event.get("validation").get("previousTimestamp").moment, "MOCK_TIME")
      )
      suite("No event log set", ()->
        setup(()->
          gsm.unset("_eventLog")
        )
        test("Creates event validation with counter of zero", ()->
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          chai.assert.equal(event.get("validation").get("counter"), 0)
        )
        test("Creates event validation with no previous id", ()->
          gsm.unset("_eventlog")
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          chai.assert.isUndefined(event.get("validation").get("previousId"))
        )
        test("Creates event validation with no previous timestamp", ()->
          gsm.unset("_eventlog")
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          chai.assert.isUndefined(event.get("validation").get("previousTimestamp"))
        )

      )
    )
    suite("logEvent", ()->
      suite("Event log is valid Backbone Collection", ()->
        gsm = null
        setup(()->
          gsm = new GameStateModel(
            _eventLog:new Backbone.Collection([
              name:"MOCK_EVENT_TYPE"
              details:"MOCK_DETAILS"
              timestamp:{moment:"MOCK_TIME"}
            ])
          )
        )
        test("Adds new event to start", ()->
          event = new Backbone.Model()
          gsm.logEvent(event)
          chai.assert.equal(gsm.get("_eventLog").length, 2)

          chai.assert.equal(gsm.get("_eventLog").at(0), event)

        )
        test("Preserves Existing Events", ()->
          gsm.logEvent({})
          chai.assert.equal(gsm.get("_eventLog").at(1).get("name"), "MOCK_EVENT_TYPE")
        )

      )
      test("No existing event log - Creates new log", ()->
        gsm = new GameStateModel()
        event = new Backbone.Model()
        gsm.logEvent(event)
        chai.assert.equal(gsm.get("_eventLog").length, 1)
        chai.assert.equal(gsm.get("_eventLog").at(0), event)
      )
      test("Invalid event log - Throws", ()->
        gsm = new GameStateModel(
          _eventLog:{}
        )
        chai.assert.throw(()->
          GameStateModel.logEvent(gsm,{})
        )
      )
    )
    suite("vivifier", ()->

      test("createsBackboneModel", ()->
        ut = GameStateModel.vivifier({}, mockType)
        chai.assert.isFunction(ut.set)
        chai.assert.isFunction(ut.unset)
        chai.assert.isFunction(ut.get)
        chai.assert.isObject(ut.attributes)
      )
      test("preservesMarshalledData", ()->
        ut = GameStateModel.vivifier(
          propA:"valA"
          propB:"valB"
        , mockType)
        chai.assert.equal(ut.get("propA"),"valA")
        chai.assert.equal(ut.get("propB"),"valB")
      )
      test("correctlyVivifiesToCorrectType", ()->
        ut = GameStateModel.vivifier(
          propA:"valA"
          propB:"valB"
        , mockType)
        chai.assert.isFunction(ut.mockMethod)
        chai.assert.equal(ut.mockMethod(),"CHEESE")
        chai.assert.instanceOf(ut, mockType)
      )

    )
  )


)