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
  Isolate.mapAsFactory("lib/backboneTools/ModelProcessor","lib/turncoat/GameStateModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      recurse:actual.recurse
      CONTINUERECURSION:actual.CONTINUERECURSION
      INORDER:actual.INORDER
    )
  )
)

define(["isolate!lib/turncoat/GameStateModel", "backbone", "lib/backboneTools/ModelProcessor", "lib/turncoat/Constants", "lib/turncoat/LogEntry", "lib/turncoat/GameHeader"], (GameStateModel, Backbone, ModelProcessor, Constants, LogEntry, GameHeader)->

  mocks = window.mockLibrary["lib/turncoat/GameStateModel"]
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
      gsm = null
      origRecurse = mocks["lib/backboneTools/ModelProcessor"].recurse
      setup(()->
        mocks["lib/backboneTools/ModelProcessor"].recurse = JsMockito.mockFunction()
        gsm = new GameStateModel()
      )
      teardown(()->
        mocks["lib/backboneTools/ModelProcessor"].recurse = origRecurse
      )
      test("Returns array", ()->
        chai.assert.isArray(gsm.searchChildren())
      )
      test("No search function set - calls ModelProcessor.recurse with default function and INORDER traversal", ()->
        gsm.searchChildren()
        JsMockito.verify(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER)
      )

      test("Search function set - calls ModelProcessor.recurse with wrapper function and INORDER traversal", ()->
        gsm.searchChildren(
          ()->true
        )
        JsMockito.verify(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER)
      )
      suite("Default checker function",()->
        setup(()->
        )
        test("Adds item checked to array",()->
          item1={}
          item2={}
          item3={}
          JsMockito.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER).then(
            (m,f)->
              f(item3)
              f(item1)
              f(item2)
          )
          list = gsm.searchChildren()
          chai.assert.equal(list[0], item3)
          chai.assert.equal(list[1], item1)
          chai.assert.equal(list[2], item2)
          chai.assert.equal(list.length, 3)
        )
        test("Returns CONTINUERECURSION",()->
          ch = null
          JsMockito.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren()
          chai.assert.equal(ch({}), ModelProcessor.CONTINUERECURSION)
        )
      )
      suite("User supplied checker function",()->
        setup(()->
        )
        test("Adds item checked to returned array if checker function returns true",()->
          item1=
            check:true
          item2=
            check:false
          item3=
            check:true
          JsMockito.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER).then(
            (m,f)->
              f(item3)
              f(item1)
              f(item2)
          )
          list = gsm.searchChildren((item)->
            item.check
          )
          chai.assert.equal(list[0], item3)
          chai.assert.equal(list[1], item1)
          chai.assert.equal(list.length, 2)
        )
        test("Returns CONTINUERECURSION",()->
          ch = null
          JsMockito.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren((item)->
            item.check
          )
          chai.assert.equal(ch({check:false}), ModelProcessor.CONTINUERECURSION)
        )
        test("Sets recurse.type - returns recurse.type",()->
          ch = null
          JsMockito.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, JsHamcrest.Matchers.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren((item, r)->
            item.check
            r.type = "MOCK RECURSION TYPE"
          )
          chai.assert.equal(ch({check:false}), "MOCK RECURSION TYPE")
        )
      )

      suite("searchGameStateModels", ()->
        scRet = {}
        gsm = null
        setup(()->
          gsm = new GameStateModel()
          gsm.searchChildren = JsMockito.mockFunction()
          JsMockito.when(gsm.searchChildren)(JsHamcrest.Matchers.func()).then((f)->
            scRet
          )
        )
        test("Calls searchChildren with default function", ()->
          gsm.searchGameStateModels()
          JsMockito.verify(gsm.searchChildren)(JsHamcrest.Matchers.func())
        )
        test("Checker function set - Calls searchChildren with wrapper function", ()->
          gsm.searchGameStateModels(()->true)
          JsMockito.verify(gsm.searchChildren)(JsHamcrest.Matchers.func())
        )
        test("Returns result of searchChildren", ()->
          chai.assert.equal(gsm.searchGameStateModels(), scRet)
        )
        suite("Checker function", ()->
          cf = null
          setup(()->
            JsMockito.when(gsm.searchChildren)(JsHamcrest.Matchers.func()).then((f)->
              cf = f
            )
          )
          suite("No checker", ()->
            setup(()->
              gsm.searchGameStateModels()
            )
            test("Returns true when supplied with GameStateModel", ()->
              chai.assert(cf(new GameStateModel()))
            )
            test("Returns false when supplied with anything else", ()->
              chai.assert.isFalse(cf(new Backbone.Model()))
              chai.assert.isFalse(cf({}))
              chai.assert.isFalse(cf(12))
            )
            test("Returns false when supplied with nothing", ()->
              chai.assert.isFalse(cf())
            )
          )
          suite("Checker specified", ()->
            checker = null
            setup(()->
              checker = JsMockito.mockFunction()
              gsm.searchGameStateModels(checker)
            )
            suite("Called with GameStateModel", ()->
              m = null
              setup(()->
                m = new GameStateModel()
              )
              test("Calls checker when supplied", ()->
                cf(m)
                JsMockito.verify(checker)(m)
              )
              test("Returns true if checker returns true", ()->
                JsMockito.when(checker)(m).then(()->true)
                chai.assert.isTrue(cf(m))
              )
              test("Returns true if checker returns truthy", ()->
                JsMockito.when(checker)(m).then(()->{})
                chai.assert(cf(m))
                JsMockito.when(checker)(m).then(()->1)
                chai.assert(cf(m))
                JsMockito.when(checker)(m).then(()->"HELLO")
                chai.assert(cf(m))
              )
              test("Returns false if checker returns false", ()->
                JsMockito.when(checker)(m).then(()->false)
                chai.assert.isFalse(cf(m))
              )
              test("Returns falsey if checker returns falsey", ()->
                JsMockito.when(checker)(m).then(()->null)
                chai.assert(!cf(m))
                JsMockito.when(checker)(m).then(()->0)
                chai.assert(!cf(m))
                JsMockito.when(checker)(m).then(()->"")
                chai.assert(!cf(m))
              )
            )
            test("Called with anything else or nothing - Returns false and doesn't call checker", ()->
              chai.assert.isFalse(cf(new Backbone.Model()))
              chai.assert.isFalse(cf({}))
              chai.assert.isFalse(cf(12))
              JsMockito.verify(checker, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
            )
          )
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
      test("State with currentUser and all other users with READY_STATE - sets userStatus as PLAYING_STATE", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_user"
            status:Constants.READY_STATE
          ,
            id:"mock_other_user"
            status:Constants.READY_STATE

          ])
        )
        chai.assert.equal(gsm.getHeaderForUser("mock_user").get("userStatus"), Constants.PLAYING_STATE)
      )
      test("State with currentUser with READY_STATE but any other users not READY_STATE  - sets userStatus as READY_STATE", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection([
            id:"mock_user"
            status:Constants.READY_STATE
          ,
            id:"mock_other_user"
            status:Constants.READY_STATE
          ,
            id:"mock_third_user"
            status:undefined

          ])
        )
        chai.assert.equal(gsm.getHeaderForUser("mock_user").get("userStatus"), Constants.READY_STATE)
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
      test("stateWithNoUsers_doesntSetUserStatus", ()->
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