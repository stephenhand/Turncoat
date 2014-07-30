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

define(["isolate!lib/turncoat/GameStateModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "backbone", "lib/backboneTools/ModelProcessor", "lib/turncoat/Constants", "lib/turncoat/LogEntry", "lib/turncoat/GameHeader"],
(GameStateModel, m, o, a, jm, v, Backbone, ModelProcessor, Constants, LogEntry, GameHeader)->

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
      #not sure why below is required but 'm' is null at this point for some reason
      m = JsHamcrest.Matchers
      mockMarshaller =
        unmarshalState:jm.mockFunction()
        marshalState:jm.mockFunction()
    )
    suite("constructor", ()->
      test("generatesValidUuidIfNotSupplied", ()->
        gsm = new GameStateModel()
        a(gsm.id, m.string())
        a(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[ab89][a-f0-9]{3}-[a-f0-9]{12}/i.test(gsm.id))
      )
      test("doesntOverwriteSuppliedUUIDEvenIfNonCompliant", ()->
        gsm = new GameStateModel(id:"MOCK_NON_COMPLIANT_UUID")
        a(gsm.id, "MOCK_NON_COMPLIANT_UUID")
      )
    )
    suite("fromString", ()->
      test("callsMarshallersUnmarshalState", ()->

        GameStateModel.marshaller = mockMarshaller
        GameStateModel.fromString("MOCK_MARSHALLED_OBJECT")
        jm.verify(mockMarshaller.unmarshalState)("MOCK_MARSHALLED_OBJECT")
      )
      test("throwsWithNoMarshallerSet", ()->
        GameStateModel.marshaller = null
        a(()->
          GameStateModel.fromString("MOCK_MARSHALLED_OBJECT")
        ,
          m.raisesAnything()
        )
      )
    )
    suite("toString", ()->
      test("callsMarshallersMarshalState", ()->
        GameStateModel.marshaller = mockMarshaller
        gsm = new GameStateModel()
        gsm.toString()
        jm.verify(mockMarshaller.marshalState)(gsm)
      )
      test("setsDefaultMarshallerWithNoMarshallerSet", ()->
        GameStateModel.marshaller = null
        gsm = new GameStateModel()
        res = gsm.toString()
        jm.verify(GameStateModel.marshaller.marshalState)(gsm)
        a(res, "MOCK_MARSHALLER_OUTPUT")
      )
    )
    suite("ghost", ()->
      gsm = null
      setup(()->
        GameStateModel.marshaller = mockMarshaller
        jm.when(mockMarshaller.marshalState)(m.anything()).then((input)->
          input.toString()
        )
        jm.when(mockMarshaller.unmarshalState)(m.anything()).then((input)->
          unmarshalledFrom:input
        )
        gsm = new GameStateModel()
        gsm.toString = ()->
          "SOMETHING"
      )
      test("calls marshalState on input", ()->
        gsm.ghost()
        jm.verify(mockMarshaller.marshalState)(gsm)
      )
      test("calls unmarshalState on marshalled data and returns result", ()->
        output = gsm.ghost()
        jm.verify(mockMarshaller.unmarshalState)("SOMETHING")
        a(output, m.hasMember("unmarshalledFrom", "SOMETHING"))
      )

    )


    suite("searchChildren", ()->
      gsm = null
      origRecurse = mocks["lib/backboneTools/ModelProcessor"].recurse
      setup(()->
        mocks["lib/backboneTools/ModelProcessor"].recurse = jm.mockFunction()
        gsm = new GameStateModel()
      )
      teardown(()->
        mocks["lib/backboneTools/ModelProcessor"].recurse = origRecurse
      )
      test("Returns array", ()->
        a(gsm.searchChildren(), m.hasMember("length"))
      )
      test("No search function set - calls ModelProcessor.recurse with default function and INORDER traversal", ()->
        gsm.searchChildren()
        jm.verify(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER)
      )

      test("Search function set - calls ModelProcessor.recurse with wrapper function and INORDER traversal", ()->
        gsm.searchChildren(
          ()->true
        )
        jm.verify(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER)
      )
      suite("Default checker function",()->
        setup(()->
        )
        test("Adds item checked to array",()->
          item1={}
          item2={}
          item3={}
          jm.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER).then(
            (m,f)->
              f(item3)
              f(item1)
              f(item2)
          )
          list = gsm.searchChildren()
          a(list[0], item3)
          a(list[1], item1)
          a(list[2], item2)
          a(list.length, 3)
        )
        test("Returns CONTINUERECURSION",()->
          ch = null
          jm.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren()
          a(ch({}), ModelProcessor.CONTINUERECURSION)
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
          jm.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER).then(
            (m,f)->
              f(item3)
              f(item1)
              f(item2)
          )
          list = gsm.searchChildren((item)->
            item.check
          )
          a(list[0], item3)
          a(list[1], item1)
          a(list.length, 2)
        )
        test("Returns CONTINUERECURSION",()->
          ch = null
          jm.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren((item)->
            item.check
          )
          a(ch({check:false}), ModelProcessor.CONTINUERECURSION)
        )
        test("Sets recurse.type - returns recurse.type",()->
          ch = null
          jm.when(mocks["lib/backboneTools/ModelProcessor"].recurse)(gsm, m.func(), ModelProcessor.INORDER).then(
            (m,f)->
              ch = f
          )
          gsm.searchChildren((item, r)->
            item.check
            r.type = "MOCK RECURSION TYPE"
          )
          a(ch({check:false}), "MOCK RECURSION TYPE")
        )
      )

      suite("searchGameStateModels", ()->
        scRet = {}
        gsm = null
        setup(()->
          gsm = new GameStateModel()
          gsm.searchChildren = jm.mockFunction()
          jm.when(gsm.searchChildren)(m.func()).then((f)->
            scRet
          )
        )
        test("Calls searchChildren with default function", ()->
          gsm.searchGameStateModels()
          jm.verify(gsm.searchChildren)(m.func())
        )
        test("Checker function set - Calls searchChildren with wrapper function", ()->
          gsm.searchGameStateModels(()->true)
          jm.verify(gsm.searchChildren)(m.func())
        )
        test("Returns result of searchChildren", ()->
          a(gsm.searchGameStateModels(), scRet)
        )
        suite("Checker function", ()->
          cf = null
          setup(()->
            jm.when(gsm.searchChildren)(m.func()).then((f)->
              cf = f
            )
          )
          suite("No checker", ()->
            setup(()->
              gsm.searchGameStateModels()
            )
            test("Returns true when supplied with GameStateModel", ()->
              a(cf(new GameStateModel()))
            )
            test("Returns false when supplied with anything else", ()->
              a(cf(new Backbone.Model()),false)
              a(cf({}), false)
              a(cf(12), false)
            )
            test("Returns false when supplied with nothing", ()->
              a(cf(), false)
            )
          )
          suite("Checker specified", ()->
            checker = null
            setup(()->
              checker = jm.mockFunction()
              gsm.searchGameStateModels(checker)
            )
            suite("Called with GameStateModel", ()->
              m = null
              setup(()->
                m = new GameStateModel()
              )
              test("Calls checker when supplied", ()->
                cf(m)
                jm.verify(checker)(m)
              )
              test("Returns true if checker returns true", ()->
                jm.when(checker)(m).then(()->true)
                a(cf(m), true)
              )
              test("Returns true if checker returns truthy", ()->
                jm.when(checker)(m).then(()->{})
                a(cf(m))
                jm.when(checker)(m).then(()->1)
                a(cf(m))
                jm.when(checker)(m).then(()->"HELLO")
                a(cf(m))
              )
              test("Returns false if checker returns false", ()->
                jm.when(checker)(m).then(()->false)
                a(cf(m), false)
              )
              test("Returns falsey if checker returns falsey", ()->
                jm.when(checker)(m).then(()->null)
                a(!cf(m))
                jm.when(checker)(m).then(()->0)
                a(!cf(m))
                jm.when(checker)(m).then(()->"")
                a(!cf(m))
              )
            )
            test("Called with anything else or nothing - Returns false and doesn't call checker", ()->
              a(cf(new Backbone.Model()), false)
              a(cf({}), false)
              a(cf(12), false)
              jm.verify(checker, v.never())(m.anything())
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
        a(res.length, 2)
        a(res[0] is gsmImmediateChild.get("child"))
        a(res[1] is gsmImmediateChild)

      )

      test("twoLevelChildSpecified_getsRootIntermediateLevelAndOwner", ()->
        res = gsmChildTwoLevelsDeep.get("child").get("child").getOwnershipChain(gsmChildTwoLevelsDeep)
        a(res.length, 3)
        a(res[0] is gsmChildTwoLevelsDeep.get("child").get("child"))
        a(res[1] is gsmChildTwoLevelsDeep.get("child"))
        a(res[2] is gsmChildTwoLevelsDeep)

      )

      test("threeLevelChildWithCollectionSpecified_getsRootIntermediateLevelsAndOwner", ()->
        res = gsmChildThreeLevelsDeep.get("child").get("child").at(0).getOwnershipChain(gsmChildThreeLevelsDeep)
        a(res.length, 4)
        a(res[0] is gsmChildThreeLevelsDeep.get("child").get("child").at(0))
        a(res[1] is gsmChildThreeLevelsDeep.get("child").get("child"))
        a(res[2] is gsmChildThreeLevelsDeep.get("child"))
        a(res[3] is gsmChildThreeLevelsDeep)
      )
    )
    suite("getHeaderForUser", ()->
      test("returns GameHeader",()->
        gh = new GameStateModel().getHeaderForUser()
        a(gh,m.instanceOf(GameHeader))
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
        a(gh.get("id"), "MOCK_SAVED_ID")
        a(gh.get("label"), "MOCK GAME TO SAVE")
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
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), "MOCK_STATUS1")
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
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), Constants.PLAYING_STATE)
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
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), Constants.READY_STATE)
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
        a(gsm.getHeaderForUser().get("userStatus"), m.nil())
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
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), m.nil())
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
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), m.nil())
      )
      test("stateWithNoUsers_doesntSetUserStatus", ()->
        gsm =new GameStateModel(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          users:new Backbone.Collection()
        )
        a(gsm.getHeaderForUser("mock_user").get("userStatus"), m.nil())
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
        a("MOCK_TIME_1", gsm.getHeaderForUser("mock_user").get("created").moment)
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
        a("MOCK_TIME_2", gsm.getHeaderForUser("mock_user").get("created").moment)
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
        a(gsm.getHeaderForUser("mock_user").get("created"), m.nil())
      )
      test("stateWithNoEventLog_doesntSetCreated", ()->
        gsm =new GameStateModel()
        a(gsm.getHeaderForUser("mock_user").get("created"), m.nil())
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
        a("MOCK_TIME_1", gsm.getHeaderForUser("mock_user").get("lastActivity").moment)
      )
      test("stateWithNoEventLog_doesntSetLastActivity", ()->
        gsm =new GameStateModel()
        a(gsm.getHeaderForUser("mock_user").get("lastActivity"), m.nil())
      )
    )
    suite("getLatestEvent", ()->
      test("gameStateModelWithoutEventLogNoEventName_ReturnsUndefined", ()->
        gsm = new GameStateModel()
        a(gsm.getLatestEvent(),m.nil())
      )
      test("gameStateModelWithoutEventLogEventName_ReturnsUndefined", ()->
        gsm = new GameStateModel()
        a(gsm.getLatestEvent("EVENT_NAME"),m.nil())
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
        a("MOCK_EVENT_TYPE",ret.get("name"))
        a("MOCK_DETAILS",ret.get("details"))
        a("MOCK_TIME",ret.get("timestamp").moment)
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
        a("MOCK_EVENT_TYPE_2",ret.get("name"))
        a("MOCK_DETAILS_2",ret.get("details"))
        a("MOCK_TIME_2",ret.get("timestamp").moment)
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
        a(gsm.getLatestEvent("MOCK_EVENT_TYPE_3"), m.nil())
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
        a(event, m.instanceOf(LogEntry))
        a(event.get("data"), "MOCK_NEW_DETAILS")
      )
      test("Uses uuid to generate id", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("id"), m.matches(/^MOCK_UUID::.+$/))

      )
      test("Creates event with supplied data", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("name"), "MOCK_NEW_EVENT")
        a(event.get("data"), "MOCK_NEW_DETAILS")
      )
      test("Creates event with current utc timestamp", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("timestamp").value, "MOCK_MOMENT_UTC:NOW")
      )
      test("Creates event with validation property", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("validation"), m.not(m.nil()))
      )
      test("Creates event validation with counter equal to current log length", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("validation").get("counter"), 3)
      )
      test("Creates event validation with previousId equal to current log's first entry ID", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("validation").get("previousId"), "MOCK ID")
      )
      test("Creates event validation with previousTimestamp equal to current log's first entry timestamp", ()->
        event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
        a(event.get("validation").get("previousTimestamp").moment, "MOCK_TIME")
      )
      suite("No event log set", ()->
        setup(()->
          gsm.unset("_eventLog")
        )
        test("Creates event validation with counter of zero", ()->
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          a(event.get("validation").get("counter"), 0)
        )
        test("Creates event validation with no previous id", ()->
          gsm.unset("_eventlog")
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          a(event.get("validation").get("previousId"), m.nil())
        )
        test("Creates event validation with no previous timestamp", ()->
          gsm.unset("_eventlog")
          event = gsm.generateEvent("MOCK_NEW_EVENT","MOCK_NEW_DETAILS")
          a(event.get("validation").get("previousTimestamp"), m.nil())
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
          a(gsm.get("_eventLog").length, 2)

          a(gsm.get("_eventLog").at(0), event)

        )
        test("Preserves Existing Events", ()->
          gsm.logEvent({})
          a(gsm.get("_eventLog").at(1).get("name"), "MOCK_EVENT_TYPE")
        )

      )
      test("No existing event log - Creates new log", ()->
        gsm = new GameStateModel()
        event = new Backbone.Model()
        gsm.logEvent(event)
        a(gsm.get("_eventLog").length, 1)
        a(gsm.get("_eventLog").at(0), event)
      )
      test("Invalid event log - Throws", ()->
        gsm = new GameStateModel(
          _eventLog:{}
        )
        a(()->
          GameStateModel.logEvent(gsm,{})
        ,
          m.raisesAnything()
        )
      )
    )
    suite("vivifier", ()->

      test("createsBackboneModel", ()->
        ut = GameStateModel.vivifier({}, mockType)
        a(ut.set, m.func())
        a(ut.unset, m.func())
        a(ut.get, m.func())
        a(ut.attributes, m.object())
      )
      test("preservesMarshalledData", ()->
        ut = GameStateModel.vivifier(
          propA:"valA"
          propB:"valB"
        , mockType)
        a(ut.get("propA"),"valA")
        a(ut.get("propB"),"valB")
      )
      test("correctlyVivifiesToCorrectType", ()->
        ut = GameStateModel.vivifier(
          propA:"valA"
          propB:"valB"
        , mockType)
        a(ut.mockMethod, m.func())
        a(ut.mockMethod(),"CHEESE")
        a(ut, m.instanceOf(mockType))
      )

    )
  )


)