require(["isolate","isolateHelper"], (Isolate, Helper)->

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
)

define(['isolate!lib/persisters/LocalStoragePersister'], (LocalStoragePersister)->
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

    #mockStoredGameTemplates =
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
      window.localStorage["current-games"] = mockStoredGames
      window.localStorage["current-invites"] = mockInvites
    )
    suite("loadUser", ()->
      test("echosProvidedStringId", ()->
        lps = new LocalStoragePersister()
        chai.assert.equal(lps.loadUser("MOCK_ID"),"MOCK_ID")
      )
      test("echosProvidedObjectId", ()->
        lps = new LocalStoragePersister()
        val={}
        chai.assert.equal(lps.loadUser(val),val)
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
    suite("loadGameList", ()->
      test("retrievesGamesIfThereAreAny", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList()
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
      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-games")
        lps = new LocalStoragePersister()
        list = lps.loadGameList()
        chai.assert.isNull(list)
      )
      test("returnsOnlyCorrectTypeOfGameIfGameTypeSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadGameList("MOCK_GAMETYPE")
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
        list = lps.loadGameList("MOCK_GAMETYPE")
        chai.assert.equal(list.length, 2)
        chai.assert.isUndefined(list[0].data)
        chai.assert.isUndefined(list[1].data)
      )

      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-games")
        lps = new LocalStoragePersister()
        list = lps.loadGameList()
        chai.assert.isNull(list)
      )
    )
    suite("retrieveGameState", ()->
      test("returnsFullUnvivifiedObjectIfCorrectIdProvided", ()->
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("MOCK_ID3")
        chai.assert.equal(game.id, "MOCK_ID3")
        chai.assert.equal(game.name, "MOCK_GAME3")
        chai.assert.equal(game._type, "MOCK_GAMETYPE")
        chai.assert.equal(game.data.prop, "MOCK_VALUE")
      )

      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-games")
        lps = new LocalStoragePersister()
        game = lps.retrieveGameState("MOCK_ID3")
        chai.assert.isNull(game)
      )
      test("throwsWithNoIdSpecified", ()->
        lps = new LocalStoragePersister()
        chai.assert.throw(()->
          lps.retrieveGameState()
        )
      )
    )
    suite("loadInviteList", ()->

      test("returnsNullIfNoGamesSaved", ()->
        window.localStorage.removeItem("current-invites")
        lps = new LocalStoragePersister()
        invites = lps.loadInviteList()
      )
      test("returnsFullListIfNoParameterSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadInviteList()
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

      test("returnsFilteredListIfInviteStatusSpecified", ()->
        lps = new LocalStoragePersister()
        list = lps.loadInviteList(
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
        list = lps.loadInviteList(
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
        list = lps.loadInviteList(
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
