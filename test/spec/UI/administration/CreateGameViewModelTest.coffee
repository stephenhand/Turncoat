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


define(['isolate!UI/administration/CreateGameViewModel', 'backbone'], (CreateGameViewModel, Backbone)->
  mocks=window.mockLibrary['UI/administration/CreateGameViewModel']
  suite("CreateGameViewModel", ()->
    setup(()->
      mocks["AppState"].createGameFromTemplate = JsMockito.mockFunction()
    )
    suite("initialize", ()->
      test("createsGameTypes", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.instanceOf(cgvm.gameTypes, Backbone.Collection)
      )

      test("watchesAppStateGameTemplates", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameTypes.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasItems(JsHamcrest.Matchers.hasMember('id','MOCK_TEMPLATE1'),JsHamcrest.Matchers.hasMember('id','MOCK_TEMPLATE2'))))
      )
      test("setsGameTypesOnSourceUpdated", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.isFunction(cgvm.gameTypes.onSourceUpdated)
      )
      test("callsGameTypesUpdateFromWatched", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameTypes.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
        chai.assert(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})))
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})))
        newM=cgvm.gameTypes.updateFromWatchedCollectionsRes.adder(new Backbone.Model({label:"A",players:3,id:"B"}))
        chai.assert.deepEqual({label:"A (3 players)",players:3,id:"B"}, newM.attributes)
      )

      test("createsSetupGameTypes", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.instanceOf(cgvm.gameSetupTypes, Backbone.Collection)
      )
      test("watchesAppStateGameTypes", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameSetupTypes.watch)(
          JsHamcrest.Matchers.hasItem(
            JsHamcrest.Matchers.hasMember(
              "models",
              JsHamcrest.Matchers.hasItems(
                JsHamcrest.Matchers.hasMember(
                  "attributes",
                  JsHamcrest.Matchers.hasMember('id','MOCK_GAME_TYPE'),
                  JsHamcrest.Matchers.hasMember('id','OTHER_MOCK_GAME_TYPE')
                )
              )
            )
          )
        )
      )
      test("setsGameSetupTypesOnSourceUpdated", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.isFunction(cgvm.gameSetupTypes.onSourceUpdated)
      )
      test("callsGameSetupTypesUpdateFromWatched", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameSetupTypes.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
        chai.assert(cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})))
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})))
        newM=cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.adder(new Backbone.Model({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"}))
        chai.assert.deepEqual({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"}, newM.attributes)

      )

      test("clonesGameTypesRatherThanReferencingOriginal", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameSetupTypes.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
        chai.assert(cgvm.gameSetupTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})))
        chai.assert.isFalse(cgvm.gameTypes.updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})))
        model=new Backbone.Model({label:"Mock Game Type",persister:"MOCK_PERSISTER",id:"B"})
        newM=cgvm.gameTypes.updateFromWatchedCollectionsRes.adder(model)
        chai.assert.notEqual(newM.attributes,model.attributes)
      )
      suite("change:selectedPlayerIdHandler", ()->
        test("ValidId_setsTemplateUsingId",()->
          cgvm = new CreateGameViewModel()

          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          chai.assert.equal(cgvm.selectedGameType.get("template").get("label"), "Another Mock Template")
        )
        test("ValidId_CopiesTemplatePlayersUserIdNameAndDescToPlayerListInOrder",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          chai.assert.equal("TEST", cgvm.selectedGameType.get("playerList").at(0).get("id"))
          chai.assert.equal("TEST NAME",cgvm.selectedGameType.get("playerList").at(0).get("name"))
          chai.assert.equal("TEST DESCRIPTION",cgvm.selectedGameType.get("playerList").at(0).get("description"))
          chai.assert.equal("TEST2", cgvm.selectedGameType.get("playerList").at(1).get("id"))
          chai.assert.equal("TEST NAME2",cgvm.selectedGameType.get("playerList").at(1).get("name"))
          chai.assert.equal("TEST DESCRIPTION 2",cgvm.selectedGameType.get("playerList").at(1).get("description"))

        )
        test("ValidId_PlayListEditsDoNotAffectTemplatePlayers",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          cgvm.selectedGameType.get("playerList").at(0).set("id", "NOT TEST")
          chai.assert.equal("TEST", cgvm.selectedGameType.get("template").get("players").at(0).get("id", "TEST"))

        )
        test("ValidId_SetPlayerForUser",()->
          cgvm = new CreateGameViewModel()
          cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
          chai.assert(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"))
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
        chai.assert.equal(cgvm.selectedGameSetupType.get("setup").get("label"), "Another Game Configuration")

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
      test("validId_setsUsersPlayerToTrueOnOnlyPlayerWithCorrectId",()->
        cgvm.selectUsersPlayer("PLAYER_1")
        chai.assert(cgvm.selectedGameType.get("playerList").at(0).get("selectedForUser"))
        chai.assert.isUndefined(cgvm.selectedGameType.get("playerList").at(1).get("selectedForUser"))

      )
      test("validId_setsUserIdToCurrentUserOnSelectedPlayer",()->
        cgvm.selectUsersPlayer("PLAYER_1")
        chai.assert.equal(cgvm.selectedGameType.get("playerList").at(0).get("user").get("id"), "MOCK_CURRENT_USER")

      )
      test("validId_unsetsUserOnPlayerThatIsUnselected",()->
        cgvm.selectUsersPlayer("PLAYER_1")
        cgvm.selectUsersPlayer("PLAYER_2")
        chai.assert.isUndefined(cgvm.selectedGameType.get("playerList").at(0).get("user"))

      )
      test("validId_doesNotSetAnythingOnTemplatePlayers",()->
        cgvm.selectUsersPlayer("PLAYER_1")
        cgvm.selectUsersPlayer("PLAYER_2")
        chai.assert.isUndefined(cgvm.selectedGameType.get("template").get("players").findWhere(selectedForUser:true))

      )
    )
    suite("validate", ()->
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
      test("playerHasEmptyUser_Fails",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).unset("user")
        chai.assert.isFalse(cgvm.validate())
      )
      test("playerHasEmptyUserId_Fails",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).set("user", new Backbone.Model())
        chai.assert.isFalse(cgvm.validate())
      )
      test("anyPlayersHaveSameUserIds_Fails",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).set("user", new Backbone.Model(id:"AN_ID"))
        chai.assert.isFalse(cgvm.validate())
      )
      test("allPlayersHaveDifferentUserIds_Passes",()->
        cgvm.selectedGameType.get("playerList").at(0).set("user", new Backbone.Model(id:"AN_ID"))
        cgvm.selectedGameType.get("playerList").at(1).set("user", new Backbone.Model(id:"ANOTHER_ID"))
        cgvm.selectedGameType.get("playerList").at(2).set("user", new Backbone.Model(id:"YET_ANOTHER_ID"))
        chai.assert.isTrue(cgvm.validate())
      )

    )

    suite("createGame", ()->
      cgvm = null
      setup(()->
        cgvm=new CreateGameViewModel()
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
      test("validPlayerList_copiesUsersFromPlayerListToTemplatePlayersWithMatchingId", ()->
        cgvm.createGame()
        JsMockito.verify(mocks["AppState"].createGameFromTemplate)(new JsHamcrest.SimpleMatcher(
          describeTo:(c)->
            "hello"
          matches:(t)->
            t.get("players").at(0).get("user") is cgvm.selectedGameType.get("playerList").at(1).get("user") &&
            t.get("players").at(1).get("user") is cgvm.selectedGameType.get("playerList").at(0).get("user")
        ))
      )
      test("validPlayerList_doesntCopySelectedForUserFlag", ()->
        cgvm.createGame()
        JsMockito.verify(mocks["AppState"].createGameFromTemplate)(new JsHamcrest.SimpleMatcher(
          describeTo:(c)->
            "hello"
          matches:(t)->
            !(t.get("players").findWhere(selectedForUser:true))?
        ))
      )
      test("CallsAppStateCreateGameFromTemplate", ()->
        cgvm=new CreateGameViewModel()
        cgvm.selectedGameType = new Backbone.Model(
          template:new Backbone.Model(
            players:new Backbone.Collection()
          )
          playerList:new Backbone.Collection()
        )
        cgvm.createGame()
        JsMockito.verify(mocks["AppState"].createGameFromTemplate)(cgvm.selectedGameType.get("template"))
      )
    )
  )



)

