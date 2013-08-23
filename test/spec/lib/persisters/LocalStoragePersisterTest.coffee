require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/GameStateModel", "lib/persisters/LocalStoragePersister", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      fromString:JsMockito.mockFunction()
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

define(['isolate!lib/persisters/LocalStoragePersister',"backbone"], (LocalStoragePersister, Backbone)->
  mocks = window.mockLibrary["lib/persisters/LocalStoragePersister"]

  suite("LocalStorage", ()->
    class MOCK_GAMETYPE

    mockStoredGames = JSON.stringify([

      name:"MOCK_GAME1"
      _type:"MOCK_GAMETYPE"
      id:"MOCK_ID1"
      data:{}
    ,
      name:"MOCK_GAME2"
      _type:"MOCK_OTHERGAMETYPE"
      id:"MOCK_ID2"
      data:{}
    ,
      name:"MOCK_GAME3"
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

    setup(()->
      window.localStorage["mock_user::current-games"] = mockStoredGames
      window.localStorage["mock_user::pending-games"] = mockInvites
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
        game=lps.loadGameTemplate("MOCK_TEMPLATE_ID2")
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
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[1].get("name"), "MOCK_GAME2")
        chai.assert.equal(list[1].get("type"), "MOCK_OTHERGAMETYPE")
        chai.assert.equal(list[1].get("id"), "MOCK_ID2")
        chai.assert.equal(list[2].get("name"), "MOCK_GAME3")
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
      test("returnsOnlyCorrectTypeOfGameIfGameTypeSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("mock_user", "MOCK_GAMETYPE")
        chai.assert.equal(list.length, 2)
        chai.assert.equal(list[0].get("name"), "MOCK_GAME1")
        chai.assert.equal(list[0].get("type"), "MOCK_GAMETYPE")
        chai.assert.equal(list[0].get("id"), "MOCK_ID1")
        chai.assert.equal(list[1].get("name"), "MOCK_GAME3")
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
    suite("retrieveGameState", ()->
      test("returnsFullUnvivifiedObjectIfCorrectUserAndIdProvided", ()->
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("mock_user","MOCK_ID3")
        chai.assert.equal(game.id, "MOCK_ID3")
        chai.assert.equal(game.name, "MOCK_GAME3")
        chai.assert.equal(game._type, "MOCK_GAMETYPE")
        chai.assert.equal(game.data.prop, "MOCK_VALUE")
      )
      test("returnsNullIfIdNotPresent", ()->
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("mock_user","MOCK_MISSING_ID")
        chai.assert.isNull(game)
      )
      test("returnsNullIfWrongPlayer", ()->
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("other_user","MOCK_ID3")
        chai.assert.isNull(game)
      )
      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("mock_user::current-games")
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("mock_user","MOCK_ID3")
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

  )


)

