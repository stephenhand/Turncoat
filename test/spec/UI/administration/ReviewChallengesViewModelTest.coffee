require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("AppState","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(kay)->
    )

  )
  Isolate.mapAsFactory("UI/BaseViewModelCollection","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockBaseViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        mockConstructedBVMC.updateFromWatchedCollections = JsMockito.mockFunction()
        mockConstructedBVMC
      mockBaseViewModelCollection
    )
  )
)

define(['isolate!UI/administration/ReviewChallengesViewModel'], (ReviewChallengesViewModel)->
  mocks = window.mockLibrary['UI/administration/ReviewChallengesViewModel']
  suite("ReviewChallengesViewModel", ()->
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([
#        id:"MOCK_GAME_ID1"
#        userStatus:"MOCK_OTHER_STATUS"
#      ,
#        id:"MOCK_GAME_ID2"
#        userStatus:"PLAYING"
#      ,
#        id:"MOCK_GAME_ID3"
#        userStatus:"MOCK_OTHER_STATUS"
      ])
      setup(()->
        mocks['AppState'].get = JsMockito.mockFunction()
        JsMockito.when(mocks['AppState'].get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            if key is "games" then mockGameList else undefined
        )
      )
      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.challenges, Backbone.Collection)
      )

      test("challengesWatchesAppStateGames", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.challenges.watch)(JsHamcrest.Matchers.hasItem(mockGameList))
      )
      test("setsChallengesOnSourceUpdated", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.isFunction(rcvm.challenges.onSourceUpdated)
      )
      suite("onSourceUpdated", ()->
        test("callsUpdateFromWatchedCollectionsWithSelectorThatFiltersOutPLAYINGUserStatus", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything(),
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                !input(new Backbone.Model({userId:"PLAYING"}))
            )
          )

        )
        test("callsUpdateFromWatchedCollectionsWithSelectorThatFiltersOutMissingUserStatus", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything(),
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                !input(new Backbone.Model({}))
            )
          )

        )
        test("callsUpdateFromWatchedCollectionsWithSelectorThatRetainsOtherUserStatus", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything(),
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                input(new Backbone.Model({userStatus:"ANYTHING_ELSE"}))
            )
          )
        )
        test("callsUpdateFromWatchedCollectionsWithSelectorThatThrowsIfNonModel", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything(),
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                try
                  input({userStatus:"ANYTHING_ELSE"})
                  false
                catch ex
                  true
            )
          )
        )
        test("callsUpdateFromWatchedCollectionsWithMatcherThatMatchesSameId", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                input(
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                ,
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                )
            ),
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything()
          )
        )
        test("callsUpdateFromWatchedCollectionsWithMatcherThatDoesntMatchesDifferentId", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.challenges.onSourceUpdated()
          JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                !input(
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                ,
                  get:(key)->
                    if key is "id" then "OTHER_ID"
                )
            ),
            JsHamcrest.Matchers.anything(),
            JsHamcrest.Matchers.anything()
          )
          test("callsUpdateFromWatchedCollectionsWithMatcherThatDoesntMatchesBothUndefinedId", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.challenges.updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.challenges.onSourceUpdated()
            JsMockito.verify(rcvm.challenges.updateFromWatchedCollections)(
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  !input(
                    get:(key)->
                  ,
                    get:(key)->
                  )
              ),
              JsHamcrest.Matchers.anything(),
              JsHamcrest.Matchers.anything()
            )
          )
        )
      )
    )
  )


)

