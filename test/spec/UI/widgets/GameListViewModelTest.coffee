
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("setTimeout","UI/widgets/GameListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret
    )
  )
  Isolate.mapAsFactory("UI/component/ObservableOrderCollection","UI/widgets/GameListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      setOrderAttribute:JsMockito.mockFunction()
    )

  )
  Isolate.mapAsFactory("AppState","UI/widgets/GameListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
        loadGame:()->
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/widgets/GameListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockViewModelCollection = Backbone.Collection.extend(
        initialize:()->
          @watch = JsMockito.mockFunction()
          @unwatch = JsMockito.mockFunction()
          @updateFromWatchedCollections = JsMockito.mockFunction()
      )
      mockViewModelCollection
    )
  )
)

define(["isolate!UI/widgets/GameListViewModel", "lib/turncoat/Constants", "jsMockito", "jsHamcrest", "chai"], (GameListViewModel, Constants, jm, h, c)->
  mocks = window.mockLibrary["UI/widgets/GameListViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("GameListViewModel", ()->
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].on = jm.mockFunction()
        mocks['AppState'].get = jm.mockFunction()
        mocks["UI/component/ObservableOrderCollection"].setOrderAttribute = jm.mockFunction()
        jm.when(mocks['AppState'].get)(m.anything()).then(
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
      test("setsUpObservableOrderingOnChallenges", ()->
        glvm = new GameListViewModel()
        jm.verify(glvm.setOrderAttribute)(m.string())
      )
      test("Challenges watches current user's games", ()->
        glvm = new GameListViewModel()
        jm.verify(glvm.watch)(m.hasItem(mockGameList))
      )
      test("Listens to AppState for changes in current user",()->
        new GameListViewModel()
        jm.verify(mocks['AppState'].on)("change::currentUser", m.func())
      )
      suite("AppState current user changed event handler", ()->
        handler = null
        currentUser = null
        glvm = null
        setup(()->
          jm.when(mocks['AppState'].on)("change::currentUser", m.func()).then(
            (n, h)->
              handler = h
          )
          glvm = new GameListViewModel()
          glvm.watch = jm.mockFunction()

        )
        test("Challenges unwatches everything", ()->
          handler.call(glvm)
          jm.verify(glvm.unwatch)()
        )
        test("Challenges watches current user's games", ()->
          handler.call(glvm)
          jm.verify(glvm.watch)(m.hasItem(mockGameList))
        )
      )
      test("Sets Challenges OnSourceUpdated", ()->
        glvm = new GameListViewModel()
        a.isFunction(glvm.onSourceUpdated)
      )
      test("Calls Challenges UpdateFromWatchedCollections", ()->
        glvm = new GameListViewModel()
        jm.verify(glvm.updateFromWatchedCollections)(
          m.anything(),
          m.anything(),
          m.anything()
        )
      )
      suite("challenges sort", ()->
        glvm = null
        setup(()->

          glvm = new GameListViewModel()
        )
        test("Created as valid moments - descending order",()->
          glvm.add(
            created:
              unix:()->5
          )
          glvm.add(
            created:
              unix:()->1
          )
          glvm.add(
            created:
              unix:()->3
          )
          a.equal(glvm.at(0).get("created").unix(), 5)
          a.equal(glvm.at(1).get("created").unix(), 3)
          a.equal(glvm.at(2).get("created").unix(), 1)
        )
        test("missingCreatedAndValidCreated_prioritisesValidMoments",()->
          glvm.add(
            created:
              unix:()->5
          )
          glvm.add({})
          glvm.add(
            created:
              unix:()->1
          )
          a.equal(glvm.at(0).get("created").unix(), 5)
          a.equal(glvm.at(1).get("created").unix(), 1)
        )
        test("invalidCreatedAndValidCreated_prioritisesValidMoments",()->
          glvm.add(created:"INVALID MOMENT")
          glvm.add(
            created:
              unix:()->2
          )
          glvm.add(
            created:
              unix:()->6
          )
          a.equal(glvm.at(0).get("created").unix(), 6)
          a.equal(glvm.at(1).get("created").unix(), 2)
          a.equal(glvm.at(2).get("created"), "INVALID MOMENT")
        )
      )
      suite("onSourceUpdated", ()->
        test("callsUpdateFromWatchedCollectionsWithMatcherThatMatchesSameId", ()->
          glvm = new GameListViewModel()
          glvm.updateFromWatchedCollections=jm.mockFunction()
          glvm.onSourceUpdated()
          jm.verify(glvm.updateFromWatchedCollections)(
            new h.SimpleMatcher(
              matches:(input)->
                input(
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                ,
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                )
            ),
            m.anything(),
            m.anything()
          )
        )
        test("Calls UpdateFromWatchedCollections with matcher that doesnt matchesDifferentId", ()->
          glvm = new GameListViewModel()
          glvm.updateFromWatchedCollections=jm.mockFunction()
          glvm.onSourceUpdated()
          jm.verify(glvm.updateFromWatchedCollections)(
            new h.SimpleMatcher(
              matches:(input)->
                !input(
                  get:(key)->
                    if key is "id" then "MOCK_ID"
                ,
                  get:(key)->
                    if key is "id" then "OTHER_ID"
                )
            ),
            m.anything(),
            m.anything()
          )
        )
        test("Calls UpdateFromWatchedCollections with matcher that doesnt match when both have undefined Id", ()->
          glvm = new GameListViewModel()
          glvm.updateFromWatchedCollections=jm.mockFunction()
          glvm.onSourceUpdated()
          jm.verify(glvm.updateFromWatchedCollections)(
            new h.SimpleMatcher(
              matches:(input)->
                !input(
                  get:(key)->
                ,
                  get:(key)->
                )
            ),
            m.anything(),
            m.anything()
          )
        )
        suite("adder", ()->
          setup(()->
            mocks["setTimeout"].func = jm.mockFunction()
          )
          test("Copies Id", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "id" then return "MOCK_ID"
                  )
                  "MOCK_ID" is ret.get("id")
              ),
              m.anything()
            )
          )
          test("Sets created text using created moment", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(

              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "created"
                        format:(pattern)->
                          "STRING FROM MOMENT: "+pattern
                  )
                  "STRING FROM MOMENT" is ret.get("createdText").substr(0,18)
              ),
              m.anything()
            )
          )
          test("Sets Created as created moment", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(

              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  moment = {}
                  ret=input(
                    get:(key)->
                      if key is "created"
                        moment
                  )
                  moment is ret.get("created")
              ),
              m.anything()
            )
          )

          test("Created isn't moment - uses placeholder", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(

              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:()->
                      "NOT_MOMENT"
                  )
                  typeof ret.get("createdText") is "string"
              ),
              m.anything()
            )
          )
          test("Created unavailable - uses placeholder", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(

              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:()->
                      undefined
                  )
                  typeof ret.get("createdText") is "string"
              ),
              m.anything()
            )
          )
          test("Copies label", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "label" then return "MOCK_LABEL"
                  )
                  "MOCK_LABEL" is ret.get("label")
              ),
              m.anything()
            )
          )
          test("User status CHALLENGED - Sets Status Text", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "userStatus" then return Constants.CHALLENGED_STATE
                  )
                  _.isString(ret.get("statusText"))
              ),
              m.anything()
            )
          )
          test("User status READY - Sets status text", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                      if key is "userStatus" then return Constants.READY_STATE
                  )
                  _.isString(ret.get("statusText"))
              ),
              m.anything()
            )
          )
          test("SetsNewTrue", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                  )
                  ret.get("new") is true
              ),
              m.anything()
            )
          )
          test("Sets timeout to unset new", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            glvm.onSourceUpdated()
            jm.verify(glvm.updateFromWatchedCollections)(
              m.anything(),
              new h.SimpleMatcher(
                matches:(input)->
                  ret=input(
                    get:(key)->
                  )
                  try
                    jm.verify(mocks["setTimeout"].func)(new h.SimpleMatcher(
                      matches:(to)->
                        to()
                        !ret.get("new")?
                    ))
                    true
                  catch e
                    false

              ),
              m.anything()
            )
          )

        )
        suite("filter",()->
          test("Set in options - calls specified filter with input and returns result", ()->
            optionFilter = jm.mockFunction()
            jm.when(optionFilter)(m.anything()).then((a)->"OPTION FILTER RESULT")
            glvm = new GameListViewModel(undefined, filter:optionFilter)
            glvm.updateFromWatchedCollections=jm.mockFunction()
            calledFilter = null
            jm.when(glvm.updateFromWatchedCollections)(
              m.anything(),
              m.anything(),
              m.func()
            ).then((a,r,f)->calledFilter = f)
            glvm.onSourceUpdated()
            a.equal(calledFilter("INPUT"), "OPTION FILTER RESULT")
            jm.verify(optionFilter)("INPUT")
          )
          test("Not set in options - always returns true", ()->
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            calledFilter = null
            jm.when(glvm.updateFromWatchedCollections)(
              m.anything(),
              m.anything(),
              m.func()
            ).then((a,r,f)->calledFilter = f)
            glvm.onSourceUpdated()
            a(calledFilter("INPUT"))
            a(calledFilter(12))
            a(calledFilter({}))
            a(calledFilter(null))
            a(calledFilter(undefined))
            a(calledFilter(false))
          )
        )
      )
    )

    suite("selectGame", ()->
      glvm = null
      setup(()->
        glvm = new GameListViewModel([
          id:"MOCK_GAME_ID1"
          userStatus:"MOCK_OTHER_STATUS"
        ,
          id:"MOCK_GAME_ID2"
          userStatus:"PLAYING"
        ,
          id:"MOCK_GAME_ID3"
          userStatus:"MOCK_OTHER_STATUS"
        ])
        glvm.trigger = jm.mockFunction()
      )
      test("Input matches id in list - triggers selectedChallengeChanged with id", ()->
        glvm.selectGame("MOCK_GAME_ID2")
        jm.verify(glvm.trigger)("selectedChallengeChanged","MOCK_GAME_ID2")
      )

      test("Input id not in list - triggers selectedChallengeChanged with nothing", ()->
        glvm.selectGame("NOT AN ID")
        jm.verify(glvm.trigger)("selectedChallengeChanged")
        jm.verify(glvm.trigger, v.never())("selectedChallengeChanged",m.anything())
      )

      test("No input - triggers selectedChallengeChanged with nothing", ()->
        glvm.selectGame()
        jm.verify(glvm.trigger)("selectedChallengeChanged")
        jm.verify(glvm.trigger, v.never())("selectedChallengeChanged",m.anything())
      )

      test("Input matches id in list - sets selected flag on matched item", ()->
        glvm.selectGame("MOCK_GAME_ID2")
        a(glvm.find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
      )

      test("Input matches id in list - unsets selected flag on not matched items", ()->
        c.set("selected", true) for c in glvm.models
        glvm.selectGame("MOCK_GAME_ID2")
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
      )
      test("Input id not in list - unsets selected flag on all", ()->
        c.set("selected", true) for c in glvm.models
        glvm.selectGame("NOT AN ID")
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
      )

      test("No input - unsets selected flag on all", ()->
        c.set("selected", true) for c in glvm.models
        glvm.selectGame("NOT AN ID")
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID1").get("selected"))
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID2").get("selected"))
        a.isUndefined(glvm.find((c)->c.get("id") is "MOCK_GAME_ID3").get("selected"))
      )

    )
  )
)

