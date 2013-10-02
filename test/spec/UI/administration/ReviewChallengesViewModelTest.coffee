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
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].get = JsMockito.mockFunction()
        JsMockito.when(mocks['AppState'].get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            if key is "games" then mockGameList else undefined
        )
      )
      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.get("challenges"), Backbone.Collection)
      )

      test("challengesWatchesAppStateGames", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").watch)(JsHamcrest.Matchers.hasItem(mockGameList))
      )
      test("setsChallengesOnSourceUpdated", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.isFunction(rcvm.get("challenges").onSourceUpdated)
      )
      test("callsChallengesUpdateFromWatchedCollections", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
          JsHamcrest.Matchers.anything(),
          JsHamcrest.Matchers.anything(),
          JsHamcrest.Matchers.anything()
        )
      )
      suite("onSourceUpdated", ()->

        test("callsUpdateFromWatchedCollectionsWithSelectorThatFiltersOutPLAYINGUserStatus", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
        )
        test("callsUpdateFromWatchedCollectionsWithMatcherThatDoesntMatchesBothUndefinedId", ()->
          rcvm = new ReviewChallengesViewModel()
          rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
          rcvm.get("challenges").onSourceUpdated()
          JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
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
        suite("adder", ()->
          test("CopiesId", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(

              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    getLatestEvent:(key)->
                      get:()->
                        format:()->
                    get:(key)->
                      if key is "id" then return "MOCK_ID"
                  )
                  "MOCK_ID" is ret.get("id")
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("SetsCreatedUsingCreatedMoment", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(

              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "created"
                        format:(pattern)->
                          "STRING FROM MOMENT: "+pattern
                  )
                  "STRING FROM MOMENT" is ret.get("created").substr(0,18)
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("CreatedNotMoment_UsesPlaceholder", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(

              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:()->
                      "NOT_MOMENT"
                  )
                  typeof ret.get("created") is "string"
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("CreatedUnavailable_UsesPlaceholder", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(

              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:()->
                      undefined
                  )
                  typeof ret.get("created") is "string"
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("CopiesLabel", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    getLatestEvent:(key)->
                      get:()->
                        format:()->
                    get:(key)->
                      if key is "label" then return "MOCK_LABEL"
                  )
                  "MOCK_LABEL" is ret.get("label")
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("UserStatusCHALLENGED_SetsStatusText", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    getLatestEvent:(key)->
                      get:()->
                        format:()->
                    get:(key)->
                      if key is "userStatus" then return "CHALLENGED"
                  )
                  _.isString(ret.get("statusText"))
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("UserStatusREADY_SetsStatusText", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    getLatestEvent:(key)->
                      get:()->
                        format:()->
                    get:(key)->
                      if key is "userStatus" then return "READY"
                  )
                  _.isString(ret.get("statusText"))
              ),
              JsHamcrest.Matchers.anything()
            )
          )
        )
        suite("selectChallenge", ()->
          rcvm = null
          setup(()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("challenges", new Backbone.Collection([
              id:"MOCK_GAME_ID1"
              userStatus:"MOCK_OTHER_STATUS"
            ,
              id:"MOCK_GAME_ID2"
              userStatus:"PLAYING"
            ,
              id:"MOCK_GAME_ID3"
              userStatus:"MOCK_OTHER_STATUS"
            ]))
          )
          test("inputMatchesIdInChallengesList_setsSelectedChallengeIdToInput", ()->
            rcvm.selectChallenge("MOCK_GAME_ID2")
            chai.assert.equal("MOCK_GAME_ID2",rcvm.get("selectedChallengeId"))
          )

          test("inputIdNotInChallengesList_unsetsSelectedChallengeId", ()->
            rcvm.selectChallenge("NOT AN ID")
            chai.assert.isUndefined(rcvm.get("selectedChallengeId"))
          )

          test("noInput_setsSelectedChallengeIdToInput", ()->
            chai.assert.isUndefined(rcvm.get("selectedChallengeId"))
          )

          test("inputMatchesIdInChallengesList_setsSelectedFlagOnMatchedItem", ()->
            rcvm.selectChallenge("MOCK_GAME_ID2")
            chai.assert(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
          )

          test("inputMatchesIdInChallengesList_unsetsSelectedFlagOnNotMatchedItem", ()->
            c.set("selected", true) for c in rcvm.get("challenges").models
            rcvm.selectChallenge("MOCK_GAME_ID2")
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
          )
          test("inputIdNotInChallengesList_unsetsSelectedFlagOnAll", ()->
            c.set("selected", true) for c in rcvm.get("challenges").models
            rcvm.selectChallenge("NOT AN ID")
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
          )
          test("noInput_unsetsSelectedFlagOnAll", ()->
            c.set("selected", true) for c in rcvm.get("challenges").models
            rcvm.selectChallenge("NOT AN ID")
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
            chai.assert.isUndefined(rcvm.get("challenges").find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
          )

        )
      )
    )
  )

)

