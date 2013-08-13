updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("AppState","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      loadGameTemplate:(id)->
        if (id is 'MOCK_TEMPLATE2')
          new Backbone.Model(
            id:"MOCK_TEMPLATE2"
            label:"Another Mock Template"
            players:new Backbone.Collection([
              new Backbone.Model(
                id:"TEST"
              )
            ])

          )
      get:(key)->
        switch key
          when "gameTemplates"
            [
              id:"MOCK_TEMPLATE1"
              label:"A Mock Template"
            ,
              id:"MOCK_TEMPLATE2"
              label:"Another Mock Template"
            ]
          when "gameTypes"
            new Backbone.Collection(
              [
                id:"MOCK_GAME_TYPE"

              ,
                id:"OTHER_MOCK_GAME_TYPE"
                label:"Another Game Configuration"
              ]
            )
          else
            null
    )
  )
  Isolate.mapAsFactory("UI/BaseViewModelCollection","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockBaseViewModelCollection = (data)->
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
      mockBaseViewModelCollection
    )
  )
)


define(['isolate!UI/administration/CreateGameViewModel', 'backbone'], (CreateGameViewModel, Backbone)->
  suite("CreateGameViewModel", ()->
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
      test("setsUpSelectedGameTypeToSetTemplateWhenIdChanges",()->
        cgvm = new CreateGameViewModel()

        cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
        chai.assert.equal(cgvm.selectedGameType.get("template").get("label"), "Another Mock Template")

      )
      test("setsUpSelectedGameTypeToSetPlayerForUserWhenIdChanges",()->
        cgvm = new CreateGameViewModel()

        cgvm.selectedGameType.set("id","MOCK_TEMPLATE2")
        chai.assert(cgvm.selectedGameType.get("template").get("players").at(0).get("selectedForUser"))

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
        )
      )
      test("validId_setsUsersPlayerToTrueOnOnlyPlayerWithCorrectId",()->
        cgvm.selectUsersPlayer("PLAYER_1")
        chai.assert(cgvm.selectedGameType.get("template").get("players").at(0).get("selectedForUser"))
        chai.assert.isUndefined(cgvm.selectedGameType.get("template").get("players").at(1).get("selectedForUser"))

      )
    )
  )


)

