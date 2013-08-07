updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("AppState","UI/administration/CreateGameViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
        get:(key)->
          if key is "gameTemplates"
            [
              id:"MOCK_TEMPLATE1"
            ,
              id:"MOCK_TEMPLATE2"
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
          updateFromWatchedCollectionsRes=
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
      test("createsGameTypes", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.instanceOf(cgvm.gameTypes, Backbone.Collection)
      )
      test("watchesAppStateGameTemplates", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameTypes.watch)(JsHamcrest.Matchers.hasItems(JsHamcrest.Matchers.hasMember('id','MOCK_TEMPLATE1'),JsHamcrest.Matchers.hasMember('id','MOCK_TEMPLATE2')))
      )
      test("setsGameTypesOnSourceUpdated", ()->
        cgvm = new CreateGameViewModel()
        chai.assert.isFunction(cgvm.gameTypes.onSourceUpdated)
      )
      test("callsGameTypesUpdateFromWatched", ()->
        cgvm = new CreateGameViewModel()
        JsMockito.verify(cgvm.gameTypes.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything())
        chai.assert(updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:1), new Backbone.Model({id:1,otherVal:2})));
        chai.assert.isFalse(updateFromWatchedCollectionsRes.comparer(new Backbone.Model(id:5), new Backbone.Model({id:1,otherVal:2})))
        chai.assert.isFalse(updateFromWatchedCollectionsRes.comparer(new Backbone.Model(), new Backbone.Model({otherVal:2})))
        newM=updateFromWatchedCollectionsRes.adder(new Backbone.Model({label:"A",players:3,id:"B"}))
        chai.assert.deepEqual({label:"A",players:3,id:"B"}, newM.attributes)
      )
    )
  )


)

