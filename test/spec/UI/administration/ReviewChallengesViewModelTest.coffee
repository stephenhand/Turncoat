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
        mocks["UI/component/ObservableOrderCollection"].setOrderAttribute = JsMockito.mockFunction()
        JsMockito.when(mocks['AppState'].get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            switch key
              when "games" then mockGameList
              when "currentUser" then new Backbone.Model(id:"MOCK_USER")
              else undefined
        )
      )
      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.get("challenges"), Backbone.Collection)
      )

      test("setsUpObservableOrderingOnChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        JsMockito.verify(rcvm.get("challenges").setOrderAttribute)(JsHamcrest.Matchers.string())
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
      suite("challenges sort", ()->
        rcvm = null
        setup(()->

          rcvm = new ReviewChallengesViewModel()
        )
        test("createdAsvalidMoments_descendingOrder",()->
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
          setup(()->
            mocks["AppState"].loadGame = JsMockito.mockFunction()
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->
              new Backbone.Model(
                label:"GAME FROM ID: "+a
                players:new Backbone.Collection([
                  id:"SELECTED_PLAYER"
                  name:"SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"MOCK_USER"
                    status:"MOCK_USER_STATUS"
                  )
                ,
                  id:"NOT_SELECTED_PLAYER"
                  name:"NOT_SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"OTHER_USER"
                    status:"OTHER_USER_STATUS"
                  )
                ])
              )
            )
          )
          test("validIdentifier_loadsGameStateUsingIdentifier", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            JsMockito.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
          )
          test("validIdentifier_setsSelectedChallengeAttributeToResult", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.equal("GAME FROM ID: AN IDENTIFIER", rcvm.get("selectedChallenge").get("label"))
          )
          test("validIdentifier_setsSelectedChallengeUserStatusAttributeToResult", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.equal("MOCK_USER_STATUS", rcvm.get("selectedChallengeUserStatus"))
          )
          test("validIdentifier_unsetsSelectedChallengeAttributeIfResultUndefined", ()->
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->)
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.isUndefined(rcvm.get("selectedChallenge"))
          )
          test("validIdentifier_unsetsSelectedChallengeUserStatusAttributeIfResultUndefined", ()->
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->)
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.isUndefined(rcvm.get("selectedChallengeUserStatus"))
          )
          test("noIdentifier_unsetsSelectedChallenge", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.unset("selectedChallengeId")
            chai.assert.isUndefined(rcvm.get("selectedChallenge"))
          )
          test("noIdentifier_unsetsSelectedChallengeUserStatus", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.unset("selectedChallengeId")
            chai.assert.isUndefined(rcvm.get("selectedChallengeUserStatus"))
          )
          test("validIdentifier_setsChallengePlayerListWithResultPlayersLabelUserAndId", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.equal(rcvm.get("challengePlayerList").at(0).get("id"),"SELECTED_PLAYER")
            chai.assert.equal(rcvm.get("challengePlayerList").at(0).get("name"),"SELECTED_PLAYER_NAME")
            chai.assert.equal(rcvm.get("challengePlayerList").at(0).get("user").get("id"),"MOCK_USER")
            chai.assert.equal(rcvm.get("challengePlayerList").at(1).get("id"),"NOT_SELECTED_PLAYER")
            chai.assert.equal(rcvm.get("challengePlayerList").at(1).get("name"),"NOT_SELECTED_PLAYER_NAME")
            chai.assert.equal(rcvm.get("challengePlayerList").at(1).get("user").get("id"),"OTHER_USER")

          )
          test("validIdentifier_setsSelectedForUserOnlyOnPlayerWithUserIdMatchingCurrentUser", ()->
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert(rcvm.get("challengePlayerList").at(0).get("selectedForUser"))
            chai.assert.isUndefined(rcvm.get("challengePlayerList").at(1).get("selectedForUser"))

          )
          test("validIdentifierNoPlayerWithCurrentUserId_doesntSetSelectedForUserOnAnything", ()->
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->
              new Backbone.Model(
                label:"GAME FROM ID: "+a
                players:new Backbone.Collection([
                  id:"SELECTED_PLAYER"
                  name:"SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"NOT_MOCK_USER"
                  )
                ,
                  id:"NOT_SELECTED_PLAYER"
                  name:"NOT_SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"OTHER_USER"
                  )
                ])
              )
            )
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.isUndefined(rcvm.get("challengePlayerList").findWhere(selectedForUser:true))

          )
          test("identifierDoesntReturnAnything_unsetsChallengePlayerList", ()->
            JsMockito.when(mocks["AppState"].loadGame)(JsHamcrest.Matchers.anything()).then((a)->)
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.set("selectedChallengeId", "AN IDENTIFIER")
            chai.assert.isUndefined(rcvm.get("challengePlayerList"))
          )
          test("noIdentifier_unsetsChallengePlayerList", ()->
            rcvm = new ReviewChallengesViewModel(selectedChallengeId:"SOMETHING")
            rcvm.set("selectedChallenge", "SOMETHING")
            rcvm.unset("selectedChallengeId")
            chai.assert.isUndefined(rcvm.get("challengePlayerList"))
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
    )
  )


)

