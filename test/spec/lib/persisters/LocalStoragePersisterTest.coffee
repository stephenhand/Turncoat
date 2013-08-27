require(["isolate","isolateHelper"], (Isolate, Helper)->
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

define(['isolate!lib/persisters/LocalStoragePersister', 'underscore',"backbone"], (LocalStoragePersister, underscore, Backbone)->
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
      _type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      data:{}
    ,
      label:"MOCK_GAME2"
      _type:"MOCK_OTHERGAMETYPE"
      id:"MOCK_ID2"
      data:{}
    ,
      label:"MOCK_GAME3"
      _type:"MOCK_GAMETYPE"
      id:"MOCK_ID3"
      data:
        prop:"MOCK_VALUE"
    ])

    mockInvites = JSON.stringify([
      name:"MOCK_GAME1"
      type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      inviter:"MOCK_INVITER1"
      time:new Date(2010,4,1)
      status:"PENDING"
    ,
      name:"MOCK_GAME2"
      type:"MOCK_OTHERGAMETYPE"
      id:"MOCK_ID2"
      inviter:"MOCK_INVITER2"
      time:new Date(2010,5,1)
      status:"PENDING"
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
      data=[]
      Storage.prototype.getItem=(key)->
        data[key]
      Storage.prototype.setItem=(key, val)->
        data[key]=val
      Storage.prototype.removeItem= (key)->
        delete data[key]
      Storage.prototype.clear = ()->
        data=[]

      data["mock_user::current-games::MOCK_ID1"] = mockGame1
      data["mock_user::current-games::MOCK_ID3"] = mockGame3
      data["mock_user::current-games"] = mockStoredGames
      data["mock_user::pending-games"] = mockInvites
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
      test("retrievesAllItemsInGameTypesArrayAsBackboneCollection",()->
        lps = new LocalStoragePersister()
        types=lps.loadGameTypes()
        chai.assert.instanceOf(types,Backbone.Collection)
        chai.assert.equal(types.length,3)
      )
    )
    suite("loadGameList", ()->
      test("retrievesGamesIfThereAreAny", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user")
        chai.assert.equal(list.length, 3)
        chai.assert.equal(list[0].get("label"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[1].get("label"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[2].get("label"), "MOCK_GAME3")
        chai.assert.equal(list[2].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[2].get("id"), "MOCK_ID3")
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
        window.localStorage.removeItem("mock_user::current-games")
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user")
        chai.assert.isNull(list)
      )
      test("GameTypeSpecified_returnsOnlyCorrectTypeOfGame", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user", "MOCK_GAMETYPE")
        chai.assert.equal(list.length, 2)
        chai.assert.equal(list[0].get("label"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[1].get("label"), "MOCK_GAME3")
        chai.assert.equal(list[1].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID3")
      )
      test("returnsOnlyTypeIdAndName", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user", "MOCK_GAMETYPE")
        chai.assert.equal(list.length, 2)
        chai.assert.isUndefined(list[0].data)
        chai.assert.isUndefined(list[1].data)
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
        window.localStorage.removeItem("mock_user::current-games::MOCK_ID3")
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
        state.toString=()->
          JSON.stringify(@)

        lps.saveGameState("mock_user",state)
        game=JSON.parse(window.localStorage.getItem("mock_user::current-games::MOCK_SAVED_ID"))
        chai.assert.equal(game.id, "MOCK_SAVED_ID")
      )

      test("validUserAndValidState_addsGameToPlayerListWithHeaderAttributes", ()->
        lps=new LocalStoragePersister()
        state =new Backbone.Model(
          id:"MOCK_SAVED_ID"
          label:"MOCK GAME TO SAVE"
          _type:"MOCK_TYPE"
          players:new Backbone.Collection()
        )
        state.toString=()->
          JSON.stringify(@)

        lps.saveGameState("mock_user",state)
        games=JSON.parse(window.localStorage.getItem("mock_user::current-games"))
        chai.assert(_.find(games,
          (game)->
            (game.id is "MOCK_SAVED_ID") &&
            (game.label is "MOCK GAME TO SAVE") &&
            (game.type is "MOCK_TYPE")
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
        chai.assert.equal(list[0].get("status"), "PENDING")

        chai.assert.equal(list[1].get("name"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[1].get("inviter"), "MOCK_INVITER2")
        chai.assert.equal(list[1].get("time").toUTCString(), new Date(2010,5,1).toUTCString())
        chai.assert.equal(list[1].get("status"), "PENDING")

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
          status:"PENDING"
        )
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "PENDING")

        chai.assert.equal(list[1].get("name"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[1].get("inviter"), "MOCK_INVITER2")
        chai.assert.equal(list[1].get("time").toUTCString(), new Date(2010,5,1).toUTCString())
        chai.assert.equal(list[1].get("status"), "PENDING")

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
        chai.assert.equal(list[0].get("status"), "PENDING")

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
          status:"PENDING"
          type:"MOCK_GAMETYPE"
        )
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[0].get("inviter"), "MOCK_INVITER1")
        chai.assert.equal(list[0].get("time").toUTCString(), new Date(2010,4,1).toUTCString())
        chai.assert.equal(list[0].get("status"), "PENDING")
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

