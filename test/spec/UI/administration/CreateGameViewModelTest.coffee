updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("AppState","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
        get:(key)->
          switch key
            when "gameTemplates"
              [
                id:"MOCK_TEMPLATE1"
              ,
                id:"MOCK_TEMPLATE2"
              ]
            when "gameTypes"
              [
                id:"MOCK_GAME_TYPE"
              ,
                id:"OTHER_MOCK_GAME_TYPE"

              ]
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
        JsMockito.verify(cgvm.gameSetupTypes.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasItems(JsHamcrest.Matchers.hasMember('id','MOCK_GAME_TYPE'),JsHamcrest.Matchers.hasMember('id','OTHER_MOCK_GAME_TYPE'))))
      )
      test("setsGameTypesOnSourceUpdated", ()->
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
    )
  )


)

