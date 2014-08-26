updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("AppState","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      createGameFromTemplate:JsMockito.mockFunction()
      loadGameTemplate:(id)->
        if (id is 'MOCK_TEMPLATE2')
          new Backbone.Model(
            id:"MOCK_TEMPLATE2"
            label:"Another Mock Template"
            players:new Backbone.Collection([
              new Backbone.Model(
                id:"TEST"
                name:"TEST NAME"
                description:"TEST DESCRIPTION"
              )
            ,
              new Backbone.Model(
                id:"TEST2"
                name:"TEST NAME2"
                description:"TEST DESCRIPTION 2"
              )
            ])

          )
      get:(key)->
        switch key
          when "gameTypes"
            new Backbone.Collection(
              [
                id:"MOCK_GAME_TYPE"

              ,
                id:"OTHER_MOCK_GAME_TYPE"
                label:"Another Game Configuration"
              ]
            )
          when "currentUser"
            new Backbone.Model(
              id:"MOCK_CURRENT_USER"
              gameTemplates:[
                id:"MOCK_TEMPLATE1"
                label:"A Mock Template"
              ,
                id:"MOCK_TEMPLATE2"
                label:"Another Mock Template"
              ]
            )
          else
            null
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockObservingViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        JsMockito.when(mockConstructedBVMC.watch)(JsHamcrest.Matchers.anything()).then((collections)->
          mockConstructedBVMC.watchedCollections = collections
        )
        mockConstructedBVMC.updateFromWatchedCollections = JsMockito.mockFunction()
        JsMockito.when(mockConstructedBVMC.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((c,a, s)->
          @updateFromWatchedCollectionsRes=
            comparer:c
            adder:a
            selector:s
        )
        mockConstructedBVMC
      mockObservingViewModelCollection
    )
  )
)


define(['isolate!UI/administration/CreateGameViewModel', "matchers", "operators", "assertThat", "jsMockito", "verifiers", "backbone"], (CreateGameViewModel, m, o, a, jm, v, Backbone)->
  mocks=window.mockLibrary['UI/administration/CreateGameViewModel']
  suite("CreateGameViewModel", ()->
    setup(()->
      mocks["AppState"].createGameFromTemplate = jm.mockFunction()
    )
    suite("initialize", ()->
      test("createsGameTypes", ()->
        cgvm = new CreateGameViewModel()
        a(cgvm.gameTypes, m.instanceOf(Backbone.Collection))
      )

      test("watchesAppStateGameTemplates", ()->
        cgvm = new CreateGameViewModel()
        jm.verify(cgvm.gameTypes.watch)(m.hasItem(m.hasItems(m.hasMember('id','MOCK_TEMPLATE1'),m.hasMember('id','MOCK_TEMPLATE2'))))
      )
      test("setsGameTypesOnSourceUpdated", ()->
        cgvm = new CreateGameViewModel()
        a(cgvm.gameTypes.onSourceUpdated, m.func())
      )
      test("callsGameTypesUpdateFromWatched", ()->
        cgvm = new CreateGameViewModel()
        jm.verify(cgvm.gameTypes.updateFromWatchedCollections)(m.anything(),m.anything())
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})), false)
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})), false)
        newM=cgvm.gameTypes.updateFromWatchedCollectionsRes.adder(new Backbone.Model({label:"A",players:3,id:"B"}))
        a(newM.attributes, m.equivalentMap({label:"A (3 players)",players:3,id:"B"}))
      )

      test("createsSetupGameTypes", ()->
        cgvm = new CreateGameViewModel()
        a(cgvm.gameSetupTypes, m.instanceOf(Backbone.Collection))
      )
      test("watchesAppStateGameTypes", ()->
        cgvm = new CreateGameViewModel()
        jm.verify(cgvm.gameSetupTypes.watch)(
          m.hasItem(
            m.hasMember(
              "models",
              m.hasItems(
                m.hasMember(
                  "attributes",
                  m.hasMember('id','MOCK_GAME_TYPE'),
                  m.hasMember('id','OTHER_MOCK_GAME_TYPE')
                )
              )
            )
          )
        )
      )
      test("setsGameSetupTypesOnSourceUpdated", ()->
        cgvm = new CreateGameViewModel()
        a(cgvm.gameSetupTypes.onSourceUpdated, m.func())
      )
      test("callsGameSetupTypesUpdateFromWatched", ()->
        cgvm = new CreateGameViewModel()
        jm.verify(cgvm.gameSetupTypes.updateFromWatchedCollections)(m.anything(),m.anything())
        a(cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})), false)
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})), false)
        newM=cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.adder(new Backbone.Model({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"}))
        a(newM.attributes,m.equivalentMap({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"}))

      )

      test("clonesGameTypesRatherThanReferencingOriginal", ()->
        cgvm = new CreateGameViewModel()
        jm.verify(cgvm.gameSetupTypes.updateFromWatchedCollections)(m.anything(),m.anything())
        a(cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})), false)
        a(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})), false)
        model=new Backbone.Model({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"})
        newM=cgvm.gameTypes.updateFromWatchedCollectionsRes.adder(model)
        a(newM.attributes,m.not(model.attributes))
      )
      suite("change:selectedPlayerIdHandler", ()->
        test("ValidId_setsTemplateUsingId",()->
          cgvm = new CreateGameViewModel()

          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          a(cgvm.selectedGameType.get("template").get("label"), "Another Mock Template")
        )
        test("ValidId_CopiesTemplatePlayersUserIdNameAndDescToPlayerListInOrder",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          a("TEST", cgvm.selectedGameType.get("playerList").at(0).get("id"))
          a("TEST NAME",cgvm.selectedGameType.get("playerList").at(0).get("name"))
          a("TEST DESCRIPTION",cgvm.selectedGameType.get("playerList").at(0).get("description"))
          a("TEST2", cgvm.selectedGameType.get("playerList").at(1).get("id"))
          a("TEST NAME2",cgvm.selectedGameType.get("playerList").at(1).get("name"))
          a("TEST DESCRIPTION 2",cgvm.selectedGameType.get("playerList").at(1).get("description"))

        )
        test("ValidId_PlayListEditsDoNotAffectTemplatePlayers",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          cgvm.selectedGameType.get("playerList").at(0).set("id", "NOT TEST")
          a("TEST", cgvm.selectedGameType.get("template").get("players").at(0).get("id", "TEST"))

        )
        test("ValidId_SetPlayerForUser",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          a(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"))
        )
      )
      test("setsUpSelectedGameSetupTypeToSetTypeWhenIdChanges",()->
        cgvm = new CreateGameViewModel()
        cgvm.gameSetupTypes = new Backbone.Collection(
          [
            id:"MOCK_GAME_TYPE"

          ,
            id:"OTHER_MOCK_GAME_TYPE"
            label:"Another Game Configuration"
          ]
        )
        cgvm.selectedGameSetupType.set("id","OTHER_MOCK_GAME_TYPE")
        a(cgvm.selectedGameSetupType.get("setup").get("label"), "Another Game Configuration")

      )
    )
    suite("selectUsersPlayer", ()->
      cgvm = null
      setup(()->
        cgvm=new CreateGameViewModel()
        cgvm.selectedGameType= new Backbone.Model(
          template:new Backbone.Model(
            players:new Backbone.Collection([
              id:"PLAYER_1"
            ,
              id:"PLAYER_2"
            ])
          )
          playerList:new Backbone.Collection([
            id:"PLAYER_1"
          ,
            id:"PLAYER_2"
          ])
        )
      )
      suite("Valid Player ID", ()->
        test("Sets selectedForUser to True on player with correct id",()->
          cgvm.selectUsersPlayer("PLAYER_1")
          a(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"))
          a(cgvm.selectedGameType.get("playerList").at(1).get("selectedForUser"), m.nil())

        )
        test("Sets id attribute to selected player on User",()->
          cgvm.selectUsersPlayer("PLAYER_1")
          a(cgvm.selectedGameType.get("playerList").at(0).get("user").get("id"), "MOCK_CURRENT_USER", m.nil())

        )
        test("Unsets user on player that is unselected",()->
          cgvm.selectUsersPlayer("PLAYER_1")
          cgvm.selectUsersPlayer("PLAYER_2")
          a(cgvm.selectedGameType.get("playerList").at(0).get("user").get("id"), m.nil())

        )
        test("Does not set anything on template players",()->
          cgvm.selectUsersPlayer("PLAYER_1")
          cgvm.selectUsersPlayer("PLAYER_2")
          a(cgvm.selectedGameType.get("template").get("players").findWhere(selectedForUser:true), m.nil())

        )
      )
      suite("Missing player", ()->
        test("Unsets selectedForUser on all players", ()->
          cgvm.selectUsersPlayer("NONSENSE")
          a(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"), m.nil())
          a(cgvm.selectedGameType.get("playerList").at(1).get("selectedForUser"), m.nil())
        )
        test("Unsets user id on any player where id matches current user", ()->
          cgvm.selectUsersPlayer("PLAYER_2")
          cgvm.selectUsersPlayer("NONSENSE")
          a(cgvm.selectedGameType.get("playerList").at(1).get("user").get("id"), m.nil())
        )
      )
      suite("No player", ()->
        test("Unsets selectedForUser on all players", ()->
          cgvm.selectUsersPlayer()
          a(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"), m.nil())
          a(cgvm.selectedGameType.get("playerList").at(1).get("selectedForUser"), m.nil())
        )
        test("Unsets user id on any player where id matches current user", ()->
          cgvm.selectUsersPlayer("PLAYER_2")
          cgvm.selectUsersPlayer()
          a(cgvm.selectedGameType.get("playerList").at(1).get("user").get("id"), m.nil())
        )
      )
    )
    suite("confirmCreateGameClicked", ()->
      cgvm = null
      setup(()->
        cgvm=new CreateGameViewModel()
        cgvm.selectedGameType= new Backbone.Model(
          playerList:new Backbone.Collection([
            id:"PLAYER_1"
          ,
            id:"PLAYER_2"
          ,
            id:"PLAYER_3"
          ])
        )
      )
      test("Player has empty user - does nothing",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).unset("user")
        cgvm.confirmCreateGameClicked()
        jm.verify(mocks["AppState"].createGameFromTemplate, v.never())(m.anything())
      )
      test("playerHasEmptyUserId - does nothing",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).set("user", new Backbone.Model())
        cgvm.confirmCreateGameClicked()
        jm.verify(mocks["AppState"].createGameFromTemplate, v.never())(m.anything())
      )
      test("anyPlayersHaveSameUserIds - does nothing",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.confirmCreateGameClicked()
        jm.verify(mocks["AppState"].createGameFromTemplate, v.never())(m.anything())
      )
      suite("All players have different user Ids _Passes",()->
        setup(()->
          cgvm.selectedGameType =  new Backbone.Model(
            template:new Backbone.Model(
              players:new Backbone.Collection([
                id:"PLAYER1"
              ,
                id:"PLAYER2"
              ])
            )
            playerList:new Backbone.Collection([
              id:"PLAYER2"
              user:new Backbone.Model(
                id:"USER2"
                prop2:"SOMETHING ELSE"
              )
              selectedForUser:true
            ,
              id:"PLAYER1"
              user:new Backbone.Model(
                id:"USER1"
                prop1:"SOMETHING"
              )
            ])
          )
        )
        test("Creates user list at top level of game containing all users assigned to players", ()->
          cgvm.confirmCreateGameClicked()
          jm.verify(mocks["AppState"].createGameFromTemplate)(new JsHamcrest.SimpleMatcher(
            describeTo: (d)->
              d.append("user list")
            matches:(t)->
              t.get("users").at(0).get("id") is cgvm.selectedGameType.get("playerList").at(0).get("user").get("id") &&
                t.get("users").at(1).get("id") is cgvm.selectedGameType.get("playerList").at(1).get("user").get("id")
          ))
        )
        test("Assigns 'playerId' property to each user matching the id of the player they were assigned to", ()->
          cgvm.confirmCreateGameClicked()
          jm.verify(mocks["AppState"].createGameFromTemplate)(new JsHamcrest.SimpleMatcher(
            describeTo: (d)->
              d.append("user list")
            matches:(t)->
              t.get("users").at(0).get("playerId") is "PLAYER2" &&
                t.get("users").at(1).get("playerId") is "PLAYER1"
          ))

        )

        test("Calls AppState CreateGame with template", ()->
          cgvm.selectedGameType = new Backbone.Model(
            template:new Backbone.Model(
              players:new Backbone.Collection()
            )
            playerList:new Backbone.Collection()
          )
          cgvm.confirmCreateGameClicked()
          jm.verify(mocks["AppState"].createGameFromTemplate)(cgvm.selectedGameType.get("template"))
        )
      )
    )
  )



)

