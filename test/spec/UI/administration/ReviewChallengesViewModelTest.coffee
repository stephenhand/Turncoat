require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("setTimeout","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
    )

  )
  Isolate.mapAsFactory("UI/component/ObservableOrderCollection","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      setOrderAttribute:JsMockito.mockFunction()
    )

  )
  Isolate.mapAsFactory("AppState","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      loadGame:()->
    )

  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockBaseViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        mockConstructedBVMC.unwatch = JsMockito.mockFunction()
        mockConstructedBVMC.updateFromWatchedCollections = JsMockito.mockFunction()
        mockConstructedBVMC
      mockBaseViewModelCollection
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelItem","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockObservingViewModelItem = (data)->
        mockObservingViewModelItem.ovmiConstructor(data)
      mockObservingViewModelItem.ovmiConstructor =  (data)->
      mockObservingViewModelItem.set = (func)->
        mockObservingViewModelItem.ovmiConstructor = func
      mockObservingViewModelItem
    )
  )
)

define(['isolate!UI/administration/ReviewChallengesViewModel'], (ReviewChallengesViewModel)->
  mocks = window.mockLibrary['UI/administration/ReviewChallengesViewModel']
  suite("ReviewChallengesViewModel", ()->
    setup(()->
      mocks["UI/component/ObservingViewModelItem"].set((data)->
        mockConstructedOVMI = new Backbone.Model(data)
        mockConstructedOVMI.watch = JsMockito.mockFunction()
        mockConstructedOVMI.unwatch = JsMockito.mockFunction()
        mockConstructedOVMI
      )
    )
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].on = JsMockito.mockFunction()
        mocks['AppState'].get = JsMockito.mockFunction()
        mocks['AppState'].issueChallenge = JsMockito.mockFunction()
        mocks['AppState'].acceptChallenge = JsMockito.mockFunction()
        mocks["UI/component/ObservableOrderCollection"].setOrderAttribute = JsMockito.mockFunction()
        JsMockito.when(mocks['AppState'].get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            switch key
              when "currentUser"
                new Backbone.Model(
                  id:"MOCK_USER"
                  games:mockGameList
                )
              else undefined
        )
      )
      test("creates empty challengePlayerList", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.get("challengePlayerList"), Backbone.Collection)
        chai.assert.equal(rcvm.get("challengePlayerList").length, 0)

      )

      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.get("challenges"), Backbone.Collection)
      )

      test("setsUpObservableOrderingOnChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").setOrderAttribute)(JsHamcrest.Matchers.string())
      )
      test("Challenges watches current user's games", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").watch)(JsHamcrest.Matchers.hasItem(mockGameList))
      )
      test("Listens to AppState for changes in current user",()->
        new ReviewChallengesViewModel()
        JsMockito.verify(mocks['AppState'].on)("change::currentUser", JsHamcrest.Matchers.func())
      )
      suite("AppState current user changed event handler", ()->
        handler = null
        currentUser = null
        rcvm = null
        setup(()->
          JsMockito.when(mocks['AppState'].on)("change::currentUser", JsHamcrest.Matchers.func()).then(
            (n, h)->
              handler = h
          )
          rcvm = new ReviewChallengesViewModel()
          rcvm.get("challenges").watch = JsMockito.mockFunction()

        )
        test("Challenges unwatches everything", ()->
          handler.call(rcvm)
          JsMockito.verify(rcvm.get("challenges").unwatch)()
        )
        test("Challenges watches current user's games", ()->
          handler.call(rcvm)
          JsMockito.verify(rcvm.get("challenges").watch)(JsHamcrest.Matchers.hasItem(mockGameList))
        )
      )
      test("Sets Challenges OnSourceUpdated", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.isFunction(rcvm.get("challenges").onSourceUpdated)
      )
      test("Calls Challenges UpdateFromWatchedCollections", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(
          JsHamcrest.Matchers.anything(),
          JsHamcrest.Matchers.anything(),
          JsHamcrest.Matchers.anything()
        )
      )
      suite("challenges sort", ()->
        rcvm = null
        setup(()->

          rcvm = new ReviewChallengesViewModel()
        )
        test("Created as valid moments - descending order",()->
          rcvm.get("challenges").add(
            created:
              unix:()->5
          )
          rcvm.get("challenges").add(
            created:
              unix:()->1
          )
          rcvm.get("challenges").add(
            created:
              unix:()->3
          )
          chai.assert.equal(rcvm.get("challenges").at(0).get("created").unix(), 5)
          chai.assert.equal(rcvm.get("challenges").at(1).get("created").unix(), 3)
          chai.assert.equal(rcvm.get("challenges").at(2).get("created").unix(), 1)
        )
        test("missingCreatedAndValidCreated_prioritisesValidMoments",()->
          rcvm.get("challenges").add(
            created:
              unix:()->5
          )
          rcvm.get("challenges").add({})
          rcvm.get("challenges").add(
            created:
              unix:()->1
          )
          chai.assert.equal(rcvm.get("challenges").at(0).get("created").unix(), 5)
          chai.assert.equal(rcvm.get("challenges").at(1).get("created").unix(), 1)
        )
        test("invalidCreatedAndValidCreated_prioritisesValidMoments",()->
          rcvm.get("challenges").add(created:"INVALID MOMENT")
          rcvm.get("challenges").add(
            created:
              unix:()->2
          )
          rcvm.get("challenges").add(
            created:
              unix:()->6
          )
          chai.assert.equal(rcvm.get("challenges").at(0).get("created").unix(), 6)
          chai.assert.equal(rcvm.get("challenges").at(1).get("created").unix(), 2)
          chai.assert.equal(rcvm.get("challenges").at(2).get("created"), "INVALID MOMENT")
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
                !input(new Backbone.Model({userStatus:"PLAYING"}))
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
          setup(()->
            mocks["setTimeout"].func = JsMockito.mockFunction()
          )
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
          test("SetsCreatedTextUsingCreatedMoment", ()->
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
                  "STRING FROM MOMENT" is ret.get("createdText").substr(0,18)
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("SetsCreatedAsCreatedMoment", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.get("challenges").updateFromWatchedCollections=JsMockito.mockFunction()
            rcvm.get("challenges").onSourceUpdated()
            JsMockito.verify(rcvm.get("challenges").updateFromWatchedCollections)(

              JsHamcrest.Matchers.anything(),
              new JsHamcrest.SimpleMatcher(
                matches:(input)->
                  moment = {}
                  ret=input(
                    get:(key)->
                      if key is "created"
                        moment
                  )
                  moment is ret.get("created")
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
                  typeof ret.get("createdText") is "string"
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
                  typeof ret.get("createdText") is "string"
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
          test("SetsNewTrue", ()->
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
                  )
                  ret.get("new") is true
              ),
              JsHamcrest.Matchers.anything()
            )
          )
          test("SetsTimeoutToUnsetNew", ()->
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
                  )
                  try
                    JsMockito.verify(mocks["setTimeout"].func)(new JsHamcrest.SimpleMatcher(
                      matches:(to)->
                        to()
                        !ret.get("new")?
                    ))
                    true
                  catch e
                    false

              ),
              JsHamcrest.Matchers.anything()
            )
          )
        )
        test("hasTabAttribute_bindsTabActiveChanged", ()->
          rcvm = new ReviewChallengesViewModel(
            tab:
              on:JsMockito.mockFunction()
          )
          JsMockito.verify(rcvm.get("tab").on)("change:active", JsHamcrest.Matchers.func())
        )
        suite("tabActiveHandler", ()->
          rcvm = null
          mockOn = JsMockito.mockFunction()
          mockGet = JsMockito.mockFunction()
          setup(()->
          )
          test("tabBecomesActive_DoesNothing", ()->
            JsMockito.when(mockGet)("active").then(()->true)
            rcvm = new ReviewChallengesViewModel(
              tab:
                on:mockOn
                get:mockGet
            )
            rcvm.selectChallenge = JsMockito.mockFunction()
            JsMockito.verify(mockOn)("change:active",new JsHamcrest.SimpleMatcher(
              describeTo:()->"tab handler"
              matches:(handler)->
                handler(rcvm.get("tab"))
                try
                  JsMockito.verify(rcvm.selectChallenge, JsMockito.Verifiers.never())()
                  true
                catch e
                  false
            ))
          )
          test("tabBecomesInactive_UnselectsChallenge", ()->
            JsMockito.when(mockGet)("active").then(()->false)
            rcvm = new ReviewChallengesViewModel(
              tab:
                on:mockOn
                get:mockGet
            )
            rcvm.selectChallenge = JsMockito.mockFunction()
            JsMockito.verify(mockOn)("change:active",new JsHamcrest.SimpleMatcher(
              describeTo:()->"tab handler"
              matches:(handler)->
                handler(rcvm.get("tab"))
                try
                  JsMockito.verify(rcvm.selectChallenge)()
                  true
                catch e
                  false
            ))
          )
        )
        suite("change:selectedChallengeId Handler", ()->
          rcvm = undefined
          setup(()->
            mocks["AppState"].loadGame = JsMockito.mockFunction()
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->
              new Backbone.Model(
                label:"GAME FROM ID: "+a
                players:new Backbone.Collection([
                  id:"SELECTED_PLAYER"
                  name:"SELECTED_PLAYER_NAME"
                ,
                  id:"NOT_SELECTED_PLAYER"
                  name:"NOT_SELECTED_PLAYER_NAME"

                ])
                users:new Backbone.Collection([
                  id:"MOCK_USER"
                  playerId:"SELECTED_PLAYER"
                  status:"MOCK_USER_STATUS"
                ,
                  id:"OTHER_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"

                ])
              )
            )

            rcvm = new ReviewChallengesViewModel()
          )
          test("Valid Identifier - Loads Game State Using Identifier", ()->
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            JsMockito.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
          )
          test("validIdentifier_setsSelectedChallengeAttributeToResult", ()->
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.equal("GAME FROM ID: AN IDENTIFIER", rcvm.get("selectedChallenge").get("label"))
          )
          test("validIdentifier_unsetsSelectedChallengeAttributeIfResultUndefined", ()->
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->)
            rcvm.set("selectedChallenge", get:()->)
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.isUndefined(rcvm.get("selectedChallenge"))
          )
          test("No identifier - unsets SelectedChallenge", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", get:()->)
            rcvm.unset("selectedChallengeId")
            chai.assert.isUndefined(rcvm.get("selectedChallenge"))
          )
          test("Valid identifier - challengePlayerList unwatches", ()->
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            JsMockito.verify(rcvm.get("challengePlayerList").unwatch)(true)
          )
          test("No identifier - challengePlayerList unwatches", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", get:()->)
            rcvm.unset("selectedChallengeId")
            JsMockito.verify(rcvm.get("challengePlayerList").unwatch)(true)
          )
          test("Valid identifier - challengePlayerList watches player list for challenge", ()->
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            JsMockito.verify(rcvm.get("challengePlayerList").watch)(JsHamcrest.Matchers.equivalentArray([rcvm.get("selectedChallenge").get("players")]))

          )
          test("Valid identifier - Calls updateFromWatchedCollection", ()->
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            JsMockito.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.func())
          )
          test("No identifier - mockWatchDataDupAttribute doesn't watch anything", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", get:()->)
            rcvm.unset("selectedChallengeId")
            JsMockito.verify(rcvm.get("challengePlayerList").watch, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
          )
          suite("OnSourceUpdated handler for challengePlayerList", ()->
            setup(()->
              rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            )
            test("Calls updateFromWatchedCollection", ()->
              rcvm.get("challengePlayerList").updateFromWatchedCollections = JsMockito.mockFunction()
              rcvm.get("challengePlayerList").onSourceUpdated()
              JsMockito.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.func())
            )
            test("Calls updateFromWatchedCollection with same handlers as when selectedChallengeId first changed", ()->
              rcvm.unset("selectedChallengeId")
              comparer = undefined
              adder = undefined
              JsMockito.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)().then((c, a)->
                comparer = c
                adder = a
              )
              rcvm.set("selectedChallengeId", "AN IDENTIFIER")
              rcvm.get("challengePlayerList").updateFromWatchedCollections = JsMockito.mockFunction()
              rcvm.get("challengePlayerList").onSourceUpdated()
              JsMockito.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(
                new JsHamcrest.SimpleMatcher(
                  matches:(cc)->
                    cc.toString() is comparer.toString()
                ),
                new JsHamcrest.SimpleMatcher(
                  matches:(aa)->
                    aa.toString() is adder.toString()
                )
              )
            )
            test("Contains player with user matching current user - sets selectedChallengeUserStatus to that user status", ()->
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              chai.assert.equal("MOCK_USER_STATUS", rcvm.get("selectedChallengeUserStatus"))
            )
            test("Contains no players with user matching current user - unsets selectedChallengeUserStatus", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"NOT_MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              chai.assert.isUndefined(rcvm.get("selectedChallengeUserStatus"))
            )
            test("Player with matching user id - sets selected for user only on player with User Id matching current user", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              chai.assert(rcvm.get("challengePlayerList").at(0).get("selectedForUser"))
              chai.assert.isUndefined(rcvm.get("challengePlayerList").at(1).get("selectedForUser"))

            )
            test("validIdentifierNoPlayerWithCurrentUserId_doesntSetSelectedForUserOnAnything", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"NOT_MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              chai.assert.isUndefined(rcvm.get("challengePlayerList").findWhere(selectedForUser:true))

            )
            suite("updateFromWatchedCollection comparer", ()->
              comparer = undefined;
              setup(()->
                JsMockito.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.func(), JsHamcrest.Matchers.nil(), JsHamcrest.Matchers.func()).then((c, a)->
                  comparer = c
                )
                rcvm.get("challengePlayerList").onSourceUpdated()
              )
              test("Matches when ids match", ()->
                chai.assert(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model(id:"MATCHING_ID")))
              )
              test("No match when ids don't match", ()->
                chai.assert.isFalse(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model(id:"NOT MATCHING_ID")))
              )
              test("No match when one id is missing", ()->
                chai.assert.isFalse(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model()))
              )
              test("No match when both ids are missing", ()->
                chai.assert.isFalse(comparer(new Backbone.Model(),new Backbone.Model()))
              )
            )
            suite("updateFromWatchedCollection adder", ()->
              adder = undefined
              addedSourceUser = undefined
              addedSource = undefined
              setup(()->
                addedSourceUser = new Backbone.Model(
                  id:"ADDED USER ID"
                  status:"ADDED USER STATUS"
                  playerId:"ADDED ID"
                  watch:JsMockito.mockFunction()
                  unwatch:JsMockito.mockFunction()
                )
                addedSource = new Backbone.Model(
                  id:"ADDED ID"
                  name:"ADDED NAME"
                  description:"ADDED DESCRIPTION"
                )
                JsMockito.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.func(), JsHamcrest.Matchers.nil(), JsHamcrest.Matchers.func()).then((c, a)->
                  adder = a
                )
                rcvm.get("selectedChallenge").get("users").push(addedSourceUser)
                rcvm.get("challengePlayerList").onSourceUpdated()
              )
              test("Copies id, description and name from input model and user status and id from located user.", ()->
                added = adder(new Backbone.Model(
                  id:"ADDED ID"
                  name:"ADDED NAME"
                  description:"ADDED DESCRIPTION"
                ))
                chai.assert.equal(added.get("id"),"ADDED ID")
                chai.assert.equal(added.get("name"),"ADDED NAME")
                chai.assert.equal(added.get("user").get("id"),"ADDED USER ID")
                chai.assert.equal(added.get("user").get("status"),"ADDED USER STATUS")
                chai.assert.equal(added.get("description"),"ADDED DESCRIPTION")
              )
              test("Id not in selectedChallenge user collection - leaves user unset", ()->
                added = adder(new Backbone.Model(
                  id:"ADDED USERLESS ID"
                  name:"ADDED NAME"
                  description:"ADDED DESCRIPTION"
                ))
                chai.assert.isUndefined(added.get("user"))
              )
              test("Ignores additional attributes on player or user", ()->
                added = adder(new Backbone.Model(
                  id:"ADDED ID"
                  name:"ADDED NAME"
                  prop1:"SOMETHING"
                  user:new Backbone.Model(
                    id:"ADDED USER"
                    status:"SOME STATUS"
                    prop1:"SOMETHING"
                  )
                  description:"ADDED DESCRIPTION"
                ))
                chai.assert.isUndefined(added.get("prop1"))
                chai.assert.isUndefined(added.get("user").get("prop1"))
              )
              test("Watches added item's name and description, user's status attributes", ()->
                added = adder(addedSource)
                JsMockito.verify(added.watch)(
                  JsHamcrest.Matchers.hasItem(
                      JsHamcrest.Matchers.allOf(
                        JsHamcrest.Matchers.hasMember("model", addedSource)
                      ,
                        JsHamcrest.Matchers.hasMember(
                          "attributes"
                        ,
                          JsHamcrest.Matchers.equivalentArray([
                            "name",
                            "description"
                          ])
                        )
                      )
                  )
                )
              )
              test("User attribute watches matched user from challenge", ()->
                added = adder(addedSource)
                JsMockito.verify(added.get("user").watch)(
                  JsHamcrest.Matchers.hasItem(
                    JsHamcrest.Matchers.allOf(
                      JsHamcrest.Matchers.hasMember("model", addedSourceUser)
                    ,
                      JsHamcrest.Matchers.hasMember(
                        "attributes"
                      ,
                        JsHamcrest.Matchers.equivalentArray([
                          "id"
                          "status"
                        ])
                      )
                    )
                  )
                )
              )
              suite("OnModelUpdated for watched items", ()->
                added = undefined
                modelUpdated = undefined
                userModelUpdated = undefined
                setup(()->
                  mocks["UI/component/ObservingViewModelItem"].set(
                    (data)->
                      ret = new Backbone.Model(data)
                      ret.watch=JsMockito.mockFunction()
                      ret.unwatch=JsMockito.mockFunction()
                      JsMockito.when(ret.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model", addedSource))).then((d)->
                        modelUpdated=ret.onModelUpdated
                      )
                      JsMockito.when(ret.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model", addedSourceUser))).then((d)->
                        userModelUpdated=ret.onModelUpdated
                      )
                      ret
                  )
                  added = adder(addedSource)
                )
                suite("Player attributes other than user modified", ()->
                  test("Sets name & description attributes on item", ()->
                    addedSource.set(
                      name:"NEW NAME"
                      description: "NEW DESCRIPTION"
                    )
                    modelUpdated(addedSource)
                    chai.assert.equal(added.get("name"), "NEW NAME")
                    chai.assert.equal(added.get("description"), "NEW DESCRIPTION")

                  )
                  test("Leaves other player attributes unmodified", ()->
                    addedSource.set(
                      id:"NEW ID"
                      name:"NEW NAME"
                      description: "NEW DESCRIPTION"
                    )
                    modelUpdated(addedSource)
                    chai.assert.equal(added.get("id"), "ADDED ID")

                  )
                )
                suite("User attributes modified", ()->
                  test("Sets id & status attributes provided from user on user", ()->
                    addedSourceUser.set(
                      status:"NEW STATUS"
                    )
                    userModelUpdated(addedSourceUser)
                    chai.assert.equal(added.get("user").get("status"), "NEW STATUS")

                  )
                  test("Unsets these attributes if not present on new model", ()->
                    addedSourceUser.unset("status")
                    userModelUpdated(addedSourceUser)
                    chai.assert.isUndefined(added.get("user").get("status"))

                  )
                  test("Leaves other existing attributes on user unmodified", ()->
                    added.get("user").set("propA", "A")
                    addedSourceUser.set(
                      status:"NEW STATUS"
                    )
                    userModelUpdated(addedSourceUser)
                    chai.assert.equal(added.get("user").get("propA"), "A")

                  )
                )

              )
            )
            suite("updateFromWatchedCollection - onremove", ()->
              removed = undefined
              remover = undefined
              setup(()->
                removed = new Backbone.Model()
                removed.watch=JsMockito.mockFunction()
                removed.unwatch=JsMockito.mockFunction()
                rcvm.get("challengePlayerList").updateFromWatchedCollections = JsMockito.mockFunction()
                JsMockito.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.func(), JsHamcrest.Matchers.nil(), JsHamcrest.Matchers.func()).then((c, a, f, r)->
                  remover = r
                )
                rcvm.get("challengePlayerList").onSourceUpdated()
              )
              test("Unwatches removed item", ()->
                remover(removed)
                JsMockito.verify(removed.unwatch)()
              )
              test("Has user - Unwatches user as well", ()->
                user = new Backbone.Model()
                user.watch=JsMockito.mockFunction()
                user.unwatch=JsMockito.mockFunction()
                removed.set("user", user)
                remover(removed)
                JsMockito.verify(user.unwatch)()
              )

            )
          )
          suite("Selected challenge user collection", ()->
            setup(()->
              rcvm.get("challengePlayerList").stopListening = JsMockito.mockFunction()
            )
            test("Challenge already selected but that challenge had no users - challengePlayerList stops listening to nothing", ()->
              rcvm.set("selectedChallenge", new Backbone.Model(
                label:"T"
                players:new Backbone.Collection([
                  id:"A"
                  name:"B"
                ,
                  id:"C"
                  name:"D"

                ])
              ))
              rcvm.set("selectedChallengeId", "AN IDENTIFIER")
              JsMockito.verify(rcvm.get("challengePlayerList").stopListening, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
            )
            test("Challenge already selected and that challenge has users - challengePlayerList stops listening to those users", ()->
              oldUsers =  new Backbone.Model()
              rcvm.set("selectedChallenge", new Backbone.Model(
                label:"T"
                players:new Backbone.Collection([
                  id:"A"
                  name:"B"
                ,
                  id:"C"
                  name:"D"

                ])
                users:oldUsers
              ))
              cl = rcvm.get("challengePlayerList")
              rcvm.set("selectedChallengeId", "AN IDENTIFIER")
              JsMockito.verify(cl.stopListening)(oldUsers)
            )
            test("New challenge has users - challengePlayerList listens to user collection's add, remove and reset methods using same handler", ()->
              handler = null
              rcvm.get("challengePlayerList").listenTo = JsMockito.mockFunction()
              JsMockito.when(rcvm.get("challengePlayerList").listenTo)(
                JsHamcrest.Matchers.anything(),
                JsHamcrest.Matchers.anything(),
                JsHamcrest.Matchers.anything(),
                JsHamcrest.Matchers.anything()
              ).then((a,b,h, d)->
                handler = h
              )
              rcvm.set("selectedChallengeId", "AN IDENTIFIER")
              JsMockito.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "add", handler, rcvm)
              JsMockito.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "remove", handler, rcvm)
              JsMockito.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "reset", handler, rcvm)
            )
            suite("Update handlers", ()->
              handler = null
              setup(()->
                mocks["UI/component/ObservingViewModelItem"].set(
                  (data)->
                    ret = new Backbone.Model(data)
                    ret.watch=JsMockito.mockFunction()
                    ret.unwatch=JsMockito.mockFunction()
                    ret
                )
                rcvm.get("challengePlayerList").push(
                  id:"SELECTED_PLAYER"
                  name:"SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"MOCK_USER"
                    status:"MOCK_USER_STATUS"
                  )
                )
                rcvm.get("challengePlayerList").last().watch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").watch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").unwatch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").push(
                  id:"NOT_SELECTED_PLAYER"
                  name:"NOT_SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"OTHER_USER"
                    status:"OTHER_USER_STATUS"
                  )
                )
                rcvm.get("challengePlayerList").last().watch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").watch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").unwatch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").push(
                  id:"USERLESS_PLAYER"
                  name:"USERLESS_PLAYER_NAME"
                )
                rcvm.get("challengePlayerList").last().watch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = JsMockito.mockFunction()
                rcvm.get("challengePlayerList").listenTo = JsMockito.mockFunction()
                JsMockito.when(rcvm.get("challengePlayerList").listenTo)(
                  JsHamcrest.Matchers.anything(),
                  JsHamcrest.Matchers.anything(),
                  JsHamcrest.Matchers.anything(),
                  JsHamcrest.Matchers.anything()
                ).then((a,b,h, d)->
                  handler = h
                )
                rcvm.set("selectedChallengeId", "AN IDENTIFIER")
              )
              test("User mapped to player changes id to invalid - removes user from player, unwatches user, leaving others in place.", ()->
                oldUser = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
                  id:"MOCK_USER"
                  playerId:"NOT A PLAYER ID"
                  status:"MOCK_USER_STATUS"
                ,
                  id:"OTHER_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"

                ])
                handler()
                JsMockito.verify(oldUser.unwatch)()
                chai.assert.isUndefined(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user"))
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                chai.assert.isUndefined(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user"))
              )
              test("User mapped to player changes removed - removes user from player, unwatches user, leaving others in place.", ()->
                oldUser = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
                  id:"OTHER_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"

                ])
                handler()
                chai.assert.isUndefined(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user"))
                JsMockito.verify(oldUser.unwatch)()
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                chai.assert.isUndefined(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user"))
              )
              test("New user added mapped to player that currently has no user - maps new user to player and watches user", ()->
                rcvm.get("selectedChallenge").get("users").reset([
                  id:"MOCK_USER"
                  playerId:"SELECTED_PLAYER"
                  status:"MOCK_USER_STATUS"
                ,
                  id:"OTHER_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"
                ,
                  id:"USERLESS_USER"
                  playerId:"USERLESS_PLAYER"
                  status:"USERLESS_STATUS"

                ])
                handler()
                chai.assert.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").id,"MOCK_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                chai.assert.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").id,"USERLESS_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").get("status"),"USERLESS_STATUS")
                JsMockito.verify(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model",rcvm.get("selectedChallenge").get("users").last())))
              )
              test("Users remapped to different players - unwatches all, reassigns, then watches again", ()->

                oldUser1 = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                oldUser2 = rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
                  id:"MOCK_USER"
                  playerId:"USERLESS_PLAYER"
                  status:"MOCK_USER_STATUS"
                ,
                  id:"OTHER_USER"
                  playerId: "SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"
                ,
                  id:"USERLESS_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"USERLESS_STATUS"

                ])
                handler()
                JsMockito.verify(oldUser1.unwatch)()
                JsMockito.verify(oldUser2.unwatch)()
                chai.assert.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").id,"MOCK_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
                chai.assert.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").id,"OTHER_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"USERLESS_USER")
                chai.assert.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"USERLESS_STATUS")
                JsMockito.verify(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model",rcvm.get("selectedChallenge").get("users").first())))
                JsMockito.verify(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model",rcvm.get("selectedChallenge").get("users").at(1))))
                JsMockito.verify(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.hasMember("model",rcvm.get("selectedChallenge").get("users").last())))
              )
            )
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
          rcvm.set("selectedChallengeId","SOMETHING",silent:true)
          rcvm.selectChallenge("NOT AN ID")
          chai.assert.isUndefined(rcvm.get("selectedChallengeId"))
        )

        test("noInput_setsSelectedChallengeIdToInput", ()->
          rcvm.set("selectedChallengeId","SOMETHING",silent:true)
          rcvm.selectChallenge()
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
      suite("issueChallenge", ()->
        rcvm = null
        setup(()->
          rcvm = new ReviewChallengesViewModel()
        )
        test("Valid identifier and challenge selected - calls AppState issueChallenge with identifier and selected game", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          rcvm.issueChallenge("ANOTHER USER")
          JsMockito.verify(mocks.AppState.issueChallenge)("ANOTHER USER", "SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.issueChallenge("ANOTHER USER")
          JsMockito.verify(mocks.AppState.issueChallenge)("ANOTHER USER", JsHamcrest.Matchers.nil())
        )
        test("No identifier - throws", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          chai.assert.throw(()->rcvm.issueChallenge())
        )
      )
      suite("acceptChallenge", ()->
        rcvm = null
        setup(()->
          rcvm = new ReviewChallengesViewModel()
        )
        test("Valid identifier and challenge selected - calls AppState issueChallenge with identifier and selected game", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          rcvm.acceptChallenge()
          JsMockito.verify(mocks.AppState.acceptChallenge)("SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.acceptChallenge()
          JsMockito.verify(mocks.AppState.acceptChallenge)(JsHamcrest.Matchers.nil())
        )
      )
    )
  )


)

