fakeBuiltMarshaller = {}

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/Factory", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      m=
        buildStateMarshaller:JsMockito.mockFunction()
        registerPersister:JsMockito.mockFunction()
      JsMockito.when(m.buildStateMarshaller)().then(()->
        fakeBuiltMarshaller
      )
      m
    )
  )
  Isolate.mapAsFactory("lib/turncoat/GameStateModel", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      fromString:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("lib/turncoat/GameStateModel", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      fromString:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("uuid", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        "MOCK_GENERATED_ID"
    )
  )
  Isolate.mapAsFactory("text!data/manOWarGameTemplates.txt", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      JSON.stringify([
        label:"MOCK GAME TEMPLATE 1"
        name:"MOCK_GAME1"
        _type:"MOCK_GAMETYPE"
        id:"MOCK_TEMPLATE_ID1"
        players:[
          {}
          {}
          {}
        ]
      ,
        label:"MOCK GAME TEMPLATE 2"
        id:"MOCK_TEMPLATE_ID2"
        players:[]
      ,
        label:"MOCK GAME TEMPLATE 3"
        id:"MOCK_TEMPLATE_ID3"
      ])
    )
  )

  Isolate.mapAsFactory("text!data/config.txt", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      JSON.stringify(gameTypes:[
        label:"MOCK GAME TYPE 1"
        name:"MOCK_GAMETYPE1"
        id:"MOCK_TEMPLATE_ID1"
        marshaller:"MOCK_MARSHALLER1"
        persister:"MOCK_PERSISTER1"
      ,
        label:"MOCK GAME TEMPLATE 2"
        id:"MOCK_TEMPLATE_ID2"
      ,
        label:"MOCK GAME TEMPLATE 3"
        id:"MOCK_TEMPLATE_ID3"
      ])
    )
  )
)

define(["isolate!lib/persisters/LocalStoragePersister", "underscore","backbone"], (LocalStoragePersister, underscore, Backbone)->
  mocks = window.mockLibrary["lib/persisters/LocalStoragePersister"]

  suite("LocalStorage", ()->
    class MOCK_GAMETYPE

    mockGame1 = JSON.stringify(
      label:"MOCK_GAME1"
      _type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      data:{}
    )

    mockGame3 = JSON.stringify(
      label:"MOCK_GAME3"
      _type:"MOCK_GAMETYPE"
      id:"MOCK_ID3"
      data:
        prop:"MOCK_VALUE"
    )
    mockStoredGames = JSON.stringify([

      label:"MOCK_GAME1"
      type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      userStatus:"CREATED"
    ,
      label:"MOCK_GAME2"
      type:"MOCK_OTHERGAMETYPE"
      id:"MOCK_ID2"
      userStatus:"CREATED"
    ,
      label:"MOCK_GAME3"
      type:"MOCK_GAMETYPE"
      id:"MOCK_ID3"
      userStatus:"REJECTED"
    ])

    mockInvites = JSON.stringify([
      name:"MOCK_GAME1"
      type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      inviter:"MOCK_INVITER1"
      time:new Date(2010,4,1)
      status:"CREATED"
    ,
      name:"MOCK_GAME2"
      type:"MOCK_OTHERGAMETYPE"
      id:"MOCK_ID2"
      inviter:"MOCK_INVITER2"
      time:new Date(2010,5,1)
      status:"CREATED"
    ,
      name:"MOCK_GAME3"
      type:"MOCK_GAMETYPE"
      id:"MOCK_ID3"
      inviter:"MOCK_INVITER3"
      time:new Date(2010,6,1)
      status:"REJECTED"
    ])
    origGet = Storage.prototype.getItem
    origSet = Storage.prototype.setItem
    origRemove = Storage.prototype.removeItem
    origClear = Storage.prototype.clear

    setup(()->
      mocks.jqueryObjects
      fakeBuiltMarshaller =
        unmarshalModel:JsMockito.mockFunction()
        marshalModel:JsMockito.mockFunction()
        unmarshalState:JsMockito.mockFunction()
        marshalState:JsMockito.mockFunction()
      data=[]
      Storage.prototype.getItem=(key)->
        data[key]
      Storage.prototype.setItem=(key, val)->
        data[key]=val
      Storage.prototype.removeItem= (key)->
        delete data[key]
      Storage.prototype.clear = ()->
        data=[]

      data["current-games::mock_user::MOCK_ID1"] = mockGame1
      data["current-games::mock_user::MOCK_ID3"] = mockGame3
      data["current-games::mock_user"] = mockStoredGames
      data["mock_user::pending-games"] = mockInvites
    )
    suite("constructor", ()->
      test("noMarshallerSupplied_usesDefaultFromMarshallerFactory",()->
        lps = new LocalStoragePersister()
        chai.assert.equal(fakeBuiltMarshaller,lps.marshaller)
      )
      test("marshallerSupplied_usesIt",()->
        m = {}
        lps = new LocalStoragePersister(m)
        chai.assert.equal(m,lps.marshaller)
      )
      test("setsStorageEventHandler",()->
        new LocalStoragePersister()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on("storage", JsHamcrest.Matchers.func()))
      )
      suite("storageEventHandler", ()->
        test("irrelevantDataUpdate_doesNothing", ()->
          lps = new LocalStoragePersister()
          lps.trigger = new JsMockito.mockFunction()
          JsMockito.verify(
            mocks.jqueryObjects.getSelectorResult(window).on("storage",
              new JsHamcrest.SimpleMatcher(
                matches:(actual)->
                  actual(
                    originalEvent:
                      key:"IRRELEVANT_KEY"
                      newValue:"IRRELEVANT_DATA"
                  )
                  JsMockito.verify(lps.trigger, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
              )
            )
          )
        )
        test("currentGamesNOQualifiersUpdate_doesNothing", ()->
          lps = new LocalStoragePersister()
          lps.trigger = new JsMockito.mockFunction()
          JsMockito.verify(
            mocks.jqueryObjects.getSelectorResult(window).on("storage",
              new JsHamcrest.SimpleMatcher(
                matches:(actual)->
                  actual(
                    originalEvent:
                      key:"current-games"
                      newValue:"IRRELEVANT_DATA"
                  )
                  JsMockito.verify(lps.trigger, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
              )
            )
          )
        )

        test("currentGamesUserSpecified_triggersGamelistUpdatedEvent", ()->
          lps = new LocalStoragePersister()
          lps.trigger = new JsMockito.mockFunction()
          JsMockito.verify(
            mocks.jqueryObjects.getSelectorResult(window).on("storage",
              new JsHamcrest.SimpleMatcher(
                matches:(actual)->
                  actual(
                    originalEvent:
                      key:"current-games::mock_user"
                      newValue:"NEW_LIST_DATA"
                  )
                  JsMockito.verify(lps.trigger)("gameListUpdated",
                    JsHamcrest.Matchers.allOf(
                      JsHamcrest.Matchers.hasMember("userId","mock_user"),
                      JsHamcrest.Matchers.hasMember("list","NEW_LIST_DATA")
                    )
                  )
              )
            )
          )
        )
        test("currentGamesUserSpecified_unmarshalsUsingUnmarshalState", ()->
          lps = new LocalStoragePersister()
          lps.trigger = new JsMockito.mockFunction()
          JsMockito.verify(
            mocks.jqueryObjects.getSelectorResult(window).on("storage",
              new JsHamcrest.SimpleMatcher(
                matches:(actual)->
                  actual(
                    originalEvent:
                      key:"current-games::mock_user"
                      newValue:"NEW_LIST_DATA"
                  )
                  JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(
                    new JsHamcrest.SimpleMatcher(
                      describeTo:(d)->
                      matches:(s)->
                        obj=JSON.parse(s)
                        obj.userId is "mock_user" and obj.list is"NEW_LIST_DATA"
                    )
                  )
              )
            )
          )
        )
      )
    )
    suite("loadUser", ()->
      test("echosProvidedStringIdInModel", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadUser("MOCK_ID").get("id"),"MOCK_ID")
      )
      test("echosProvidedObjectIdInModel", ()->
        lps = new LocalStoragePersister()
        val={}
        chai.assert.equal(lps.loadUser(val).get("id"),val)
      )
      test("throwsIfUndefined", ()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->lps.loadUser())
      )
      test("throwsIfNull", ()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->lps.loadUser(null))
      )

    )
    suite("loadGameTemplatesList", ()->
      setup(()->
        JsMockito.when(fakeBuiltMarshaller.unmarshalModel)(JsHamcrest.Matchers.anything()).then((a)->
          new Backbone.Collection([
            label:"MOCK GAME TEMPLATE 1"
            name:"MOCK_GAME1"
            _type:"MOCK_GAMETYPE"
            id:"MOCK_TEMPLATE_ID1"
            players:[
              {}
              {}
              {}
            ]
          ,
            label:"MOCK GAME TEMPLATE 2"
            id:"MOCK_TEMPLATE_ID2"
            players:[]
          ,
            label:"MOCK GAME TEMPLATE 3"
            id:"MOCK_TEMPLATE_ID3"
          ])
        )
      )
      test("generatesItemPerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadGameTemplateList().length,3)
      )
      test("setsCorrectLabelPerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.deepEqual(["MOCK GAME TEMPLATE 1", "MOCK GAME TEMPLATE 2", "MOCK GAME TEMPLATE 3"],(t.get("label") for t in lps.loadGameTemplateList().models))
      )
      test("setsCorrectIdPerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.deepEqual(["MOCK_TEMPLATE_ID1", "MOCK_TEMPLATE_ID2", "MOCK_TEMPLATE_ID3"],(t.get("id") for t in lps.loadGameTemplateList().models))
      )
      test("setsPlayersTo3For3PlayerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadGameTemplateList().at(0).get("players"),3)
      )
      test("setsPlayersTo0ForEmptyPlayerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadGameTemplateList().at(1).get("players"),0)
      )
      test("leavesPlayersUndefinedForUndefinedPlayerTemplate", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadGameTemplateList().at(2).get("players"),undefined)
      )
    )
    suite("loadGameTemplate", ()->
      gsmInput=null
      setup(()->
        JsMockito.when(fakeBuiltMarshaller.unmarshalModel)(JsHamcrest.Matchers.anything()).then((a)->
          new Backbone.Collection([
            label:"MOCK GAME TYPE 1"
            name:"MOCK_GAMETYPE1"
            id:"MOCK_TEMPLATE_ID1"
            marshaller:"MOCK_MARSHALLER1"
            persister:"MOCK_PERSISTER1"
          ,
            label:"MOCK GAME TEMPLATE 2"
            id:"MOCK_TEMPLATE_ID2"
          ,
            label:"MOCK GAME TEMPLATE 3"
            id:"MOCK_TEMPLATE_ID3"
          ])
        )
        JsMockito.when(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.anything()).then(
          (a)->
            JSON.stringify(a.attributes)
        )
        mocks["lib/turncoat/GameStateModel"].fromString=JsMockito.mockFunction()
        JsMockito.when(mocks["lib/turncoat/GameStateModel"].fromString)(JsHamcrest.Matchers.anything()).then((a)->
          gsmInput=a
        )
      )
      test("validTemplateId_callsGameStateModelFromStringOnTemplateWithId",()->
        lps = new LocalStoragePersister()
        lps.loadGameTemplate("MOCK_TEMPLATE_ID2")
        JsMockito.verify(mocks["lib/turncoat/GameStateModel"].fromString)(JsHamcrest.Matchers.containsString("MOCK_TEMPLATE_ID2"))
      )
      test("validTemplateId_callsGameStateModelFromStringWithValidJSON",()->
        lps = new LocalStoragePersister()
        lps.loadGameTemplate("MOCK_TEMPLATE_ID2")
        chai.assert.doesNotThrow(()->
          JSON.parse(gsmInput)
        )
      )
      test("validTemplateId_callsGameStateModelFromStringWithValidJSONWithCorrectData",()->
        lps = new LocalStoragePersister()
        lps.loadGameTemplate("MOCK_TEMPLATE_ID2")
        chai.assert.equal(JSON.parse(gsmInput).label, "MOCK GAME TEMPLATE 2")
      )
      test("missingId_throws",()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->
          lps.loadGameTemplate("MOCK_TEMPLATE_MISSINGID")
        )
      )
      test("undefinedId_throws",()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->
          lps.loadGameTemplate()
        )
      )
    )
    suite("loadGameTypes", ()->
      setup(()->
        JsMockito.when(fakeBuiltMarshaller.unmarshalModel)(JsHamcrest.Matchers.anything()).then((a)->
          new Backbone.Model(
            gameTypes:new Backbone.Collection([
              label:"MOCK GAME TYPE 1"
              name:"MOCK_GAMETYPE1"
              id:"MOCK_TEMPLATE_ID1"
              marshaller:"MOCK_MARSHALLER1"
              persister:"MOCK_PERSISTER1"
            ,
              label:"MOCK GAME TEMPLATE 2"
              id:"MOCK_TEMPLATE_ID2"
            ,
              label:"MOCK GAME TEMPLATE 3"
              id:"MOCK_TEMPLATE_ID3"
            ])
          )
        )
      )
      test("retrievesAllItemsInGameTypesArrayAsBackboneCollection",()->
        lps = new LocalStoragePersister()
        types=lps.loadGameTypes()
        chai.assert.instanceOf(types,Backbone.Collection)
        chai.assert.equal(types.length,3)
      )
    )
    suite("loadGameList", ()->
      setup(()->
        JsMockito.when(fakeBuiltMarshaller.unmarshalState)(JsHamcrest.Matchers.anything()).then((a)->
          p =JSON.parse(a)
          if p instanceof Array
            return new Backbone.Collection(p)
          else
            return new Backbone.Model(p)
        )
      )
      test("retrievesGamesIfThereAreAny", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user")
        chai.assert.equal(list.length, 3)
        chai.assert.equal(list.at(0).get("label"), "MOCK_GAME1")
        chai.assert.equal(list.at(0).get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list.at(0).get("id"), "MOCK_ID1")
        chai.assert.equal(list.at(0).get("userStatus"),"CREATED")
        chai.assert.equal(list.at(1).get("label"), "MOCK_GAME2")
        chai.assert.equal(list.at(1).get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list.at(1).get("id"), "MOCK_ID2")
        chai.assert.equal(list.at(1).get("userStatus"),"CREATED")
        chai.assert.equal(list.at(2).get("label"), "MOCK_GAME3")
        chai.assert.equal(list.at(2).get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list.at(2).get("id"), "MOCK_ID3")
        chai.assert.equal(list.at(2).get("userStatus"),"REJECTED")
      )
      test("returnsNullIfWrongPlayer", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("other_user")
        chai.assert.isNull(list)
      )
      test("throwsIfNoPlayer", ()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->lps.loadGameList())
      )
      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-games::mock_user")
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user")
        chai.assert.isNull(list)
      )
      test("GameTypeSpecified_returnsOnlyCorrectTypeOfGame", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user", "MOCK_GAMETYPE")
        chai.assert.equal(list.length, 2)
        chai.assert.equal(list.at(0).get("label"), "MOCK_GAME1")
        chai.assert.equal(list.at(0).get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list.at(0).get("id"), "MOCK_ID1")
        chai.assert.equal(list.at(1).get("label"), "MOCK_GAME3")
        chai.assert.equal(list.at(1).get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list.at(1).get("id"), "MOCK_ID3")
      )

    )
    suite("loadGameState", ()->
      setup(()->
        JsMockito.when(mocks["lib/turncoat/GameStateModel"].fromString)(JsHamcrest.Matchers.anything()).then((data)->
          originalInput:data
        )
      )
      test("CorrectUserAndIdProvided_callsFromStringOnData", ()->
        lps = new LocalStoragePersister()
        game = lps.loadGameState("mock_user","MOCK_ID3")
        JsMockito.verify(mocks["lib/turncoat/GameStateModel"].fromString)(mockGame3)
      )
      test("CorrectUserAndIdProvided_returnsFullVivifiedObject", ()->
        lps = new LocalStoragePersister()
        game = lps.loadGameState("mock_user","MOCK_ID3")
        chai.assert.equal(game.originalInput,mockGame3)
      )
      test("returnsNullIfIdNotPresent", ()->
        lps = new LocalStoragePersister()
        game = lps.loadGameState("mock_user","MOCK_MISSING_ID")
        chai.assert.isNull(game)
      )
      test("returnsNullIfWrongPlayer", ()->
        lps = new LocalStoragePersister()
        game = lps.loadGameState("other_user","MOCK_ID3")
        chai.assert.isNull(game)
      )
      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-games::mock_user::MOCK_ID3")
        lps = new LocalStoragePersister()
        game = lps.loadGameState("mock_user","MOCK_ID3")
        chai.assert.isNull(game)
      )
      test("throwsWithNoIdSpecified", ()->
        lps = new LocalStoragePersister()
        chai.assert.throw(()->
          lps.retrieveGameState("mock_user")
        )
      )
      test("throwsWithNothingSpecified", ()->
        lps = new LocalStoragePersister()
        chai.assert.throw(()->
          lps.retrieveGameState()
        )
      )
    )
    suite("saveGameState",()->
      setup(()->
        JsMockito.when(fakeBuiltMarshaller.unmarshalState)(JsHamcrest.Matchers.anything()).then(
          (a)->
            p =JSON.parse(a)
            if p instanceof Array
              new Backbone.Collection(p)
            else
              new Backbone.Model(p)
        )
        JsMockito.when(fakeBuiltMarshaller.marshalState)(JsHamcrest.Matchers.anything()).then(
          (a)->
            JSON.stringify(a)
        )
      )
      test("noParameters_throws", ()->
        lps=new LocalStoragePersister()
        chai.assert.throws(()->
          lps.saveGameState()
        )

      )
      test("noUser_throws", ()->
        lps=new LocalStoragePersister()
        chai.assert.throws(()->
          lps.saveGameState(null, {})
        )

      )
      test("noState_throws", ()->
        lps=new LocalStoragePersister()
        chai.assert.throws(()->
          lps.saveGameState({})
        )

      )
      test("validUserAndValidState_storesGameAtCorrectLocation", ()->
        lps=new LocalStoragePersister()
        state =new Backbone.Model(
          id:"MOCK_SAVED_ID"
          players:new Backbone.Collection()
        )
        state.getHeaderForUser = JsMockito.mockFunction()
        JsMockito.when(state.getHeaderForUser)(JsHamcrest.Matchers.anything()).then(()->HEADER_FOR:state.get("id"))
        state.toString=()->
          JSON.stringify(@)
        lps.saveGameState("mock_user",state)
        game=JSON.parse(window.localStorage.getItem("current-games::mock_user::MOCK_SAVED_ID"))
        chai.assert.equal(game.id, "MOCK_SAVED_ID")
      )

      test("validUserAndValidState_addsGameHeaderCalledWithSuppliedUserToPlayerList", ()->
        lps=new LocalStoragePersister()
        state =new Backbone.Model(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          players:new Backbone.Collection()
        )
        state.getHeaderForUser = JsMockito.mockFunction()
        JsMockito.when(state.getHeaderForUser)(JsHamcrest.Matchers.anything()).then((usr)->HEADER_FOR:usr+"::"+state.get("id"))
        state.toString=()->
          JSON.stringify(@)

        lps.saveGameState("mock_user",state)
        games=JSON.parse(window.localStorage.getItem("current-games::mock_user"))
        chai.assert(_.find(
          games,
          (game)->
            game.HEADER_FOR is "mock_user::MOCK_SAVED_ID"
          )
        )
      )
      test("validUserAndValidState_leavesOtherGamesInList", ()->
        lps=new LocalStoragePersister()
        state =new Backbone.Model(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          players:new Backbone.Collection()
        )
        state.getHeaderForUser = JsMockito.mockFunction()
        JsMockito.when(state.getHeaderForUser)(JsHamcrest.Matchers.anything()).then(()->HEADER_FOR:state.get("id"))
        state.toString=()->
          JSON.stringify(@)

        lps.saveGameState("mock_user",state)
        games=JSON.parse(window.localStorage.getItem("current-games::mock_user"))
        chai.assert(_.find(
          games,
          (game)->
            (game.id is "MOCK_ID1") &&
            (game.label is "MOCK_GAME1")
          )
        )
        chai.assert(_.find(
          games,
          (game)->
            (game.id is "MOCK_ID2") &&
            (game.label is "MOCK_GAME2")
          )
        )
        chai.assert(_.find(
          games,
          (game)->
            (game.id is "MOCK_ID3") &&
            (game.label is "MOCK_GAME3")
          )
        )
      )
      test("validUserAndValidState_triggersGameListUpdatedEvent", ()->
        lps=new LocalStoragePersister()
        lps.trigger = JsMockito.mockFunction()
        state =new Backbone.Model(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          players:new Backbone.Collection()
        )
        state.getHeaderForUser = JsMockito.mockFunction()
        JsMockito.when(state.getHeaderForUser)(JsHamcrest.Matchers.anything()).then((usr)->HEADER_FOR:usr+"::"+state.get("id"))
        state.toString=()->
          JSON.stringify(@)

        lps.saveGameState("mock_user",state)
        games=JSON.parse(window.localStorage.getItem("current-games::mock_user"))
        JsMockito.verify(lps.trigger)(
          "gameListUpdated",
          new JsHamcrest.SimpleMatcher(
            matches:(gl)->
              gl.userId is "mock_user"

          )
        )
      )
    )
    suite("loadPendingGamesList", ()->

      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("mock_user::pending-games")
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("mock_user")
        chai.assert.isNull(list)
      )
      test("throwsIfNoUserSpecified", ()->
        lps = new LocalStoragePersister()
        chai.assert.throws(()->lps.loadPendingGamesList())
      )
      test("returnsFullListIfOnlyUserSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("mock_user")
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "CREATED")

        chai.assert.equal(list[1].get("name"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[1].get("inviter"), "MOCK_INVITER2")
        chai.assert.equal(list[1].get("time").toUTCString(), new Date(2010,5,1).toUTCString())
        chai.assert.equal(list[1].get("status"), "CREATED")

        chai.assert.equal(list[2].get("name"), "MOCK_GAME3")
        chai.assert.equal(list[2].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[2].get("id"), "MOCK_ID3")
        chai.assert.equal(list[2].get("inviter"), "MOCK_INVITER3")
        chai.assert.equal(list[2].get("time").toUTCString(), new Date(2010,6,1).toUTCString())
        chai.assert.equal(list[2].get("status"), "REJECTED")
      )
      test("returnsNullIfWrongUserSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("other_user")
        chai.assert.isNull(list)

      )
      test("returnsFilteredListIfInviteStatusSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("mock_user",
          status:"CREATED"
        )
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "CREATED")

        chai.assert.equal(list[1].get("name"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[1].get("inviter"), "MOCK_INVITER2")
        chai.assert.equal(list[1].get("time").toUTCString(), new Date(2010,5,1).toUTCString())
        chai.assert.equal(list[1].get("status"), "CREATED")

      )

      test("returnsFilteredListIfGameTypeSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("mock_user",
          type:"MOCK_GAMETYPE"
        )
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "CREATED")

        chai.assert.equal(list[1].get("name"), "MOCK_GAME3")
        chai.assert.equal(list[1].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID3")
        chai.assert.equal(list[1].get("inviter"), "MOCK_INVITER3")
        chai.assert.equal(list[1].get("time").toUTCString(), new Date(2010,6,1).toUTCString())
        chai.assert.equal(list[1].get("status"), "REJECTED")
      )

      test("returnsFilteredListIfBothSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadPendingGamesList("mock_user",
          status:"CREATED"
          type:"MOCK_GAMETYPE"
        )
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "CREATED")
      )
    )
    teardown(()->
      Storage.prototype.getItem = origGet
      Storage.prototype.setItem = origSet
      Storage.prototype.removeItem = origRemove
      Storage.prototype.clear = origClear
    )
  )


)

