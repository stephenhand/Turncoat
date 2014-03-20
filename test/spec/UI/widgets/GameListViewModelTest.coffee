
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
  Isolate.mapAsFactory("UI/component/ObservingViewModelItem","UI/widgets/GameListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockViewModelCollection = Backbone.Model.extend(
        initialize:()->
          @watch = JsMockito.mockFunction()
          @unwatch = JsMockito.mockFunction()
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
        jm.verify(glvm.watch)(m.hasItem(mockGameList),m.anything())
      )
      test("Challenges watches current user's game's userStatus attribute", ()->
        glvm = new GameListViewModel()
        jm.verify(glvm.watch)(m.anything(), m.equivalentArray(["userStatus"]))
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
          jm.verify(glvm.watch)(m.hasItem(mockGameList),m.anything())
        )
        test("Challenges watches current user's game's userStatus attribute", ()->
          handler.call(glvm)
          jm.verify(glvm.watch)(m.anything(), m.equivalentArray(["userStatus"]))
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
          adder = null
          glvm = null
          setup(()->
            mocks["setTimeout"].func = jm.mockFunction()
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            jm.when(glvm.updateFromWatchedCollections)(
              m.anything(),
              m.func(),
              m.anything(),
              m.anything()).then((a,b,c,d)->
                adder = b
            )
            glvm.onSourceUpdated()
          )
          test("Copies Id", ()->
            a.equal(adder(new Backbone.Model(
              id:"MOCK_ID"
            )).get("id"),"MOCK_ID")
          )
          test("Sets created text using created moment", ()->
            a.equal(adder(
              get:(key)->
                if key is "created"
                  format:(pattern)->
                    "STRING FROM MOMENT: "+pattern).get("createdText").substr(0,18),"STRING FROM MOMENT")
          )
          test("Sets Created as created moment", ()->
            a.equal(adder(
              get:(key)->
                if key is "created"
                  moment
            ).get("created"), moment)
          )

          test("Created isn't moment - uses placeholder", ()->
            a.isString(adder(
              get:()->
                "NOT_MOMENT"
            ).get("createdText"))
          )
          test("Created unavailable - uses placeholder", ()->
            a.isString(adder(
              get:()->
                undefined
            ).get("createdText"))
          )
          test("Copies label", ()->
            a.equal(adder(
              get:(key)->
                if key is "label" then return "MOCK_LABEL"
            ).get("label"), "MOCK_LABEL")
          )
          test("User status CHALLENGED - Sets Status Text", ()->
            a.isString(adder(
              get:(key)->
                if key is "userStatus" then return Constants.CHALLENGED_STATE
            ).get("statusText"))
          )
          test("User status READY - Sets status text", ()->
            a.isString(adder(
              get:(key)->
                if key is "userStatus" then return Constants.READY_STATE
            ).get("statusText"))
          )
          test("SetsNewTrue", ()->
            a.isTrue(adder(
              get:(key)->
            ).get("new"))
          )
          test("Sets timeout to unset new", ()->
            model =
              get:(key)->
            adder(model)
            jm.verify(mocks["setTimeout"].func)(new h.SimpleMatcher(
              matches:(to)->
                to()
                !model.get("new")?
            ))
          )
          test("Sets modelUpdated on new item", ()->
            a.isFunction(adder(
              get:(key)->
            ).onModelUpdated)
          )
          suite("modelUpdated handler", ()->
            handler = null
            outModel = null
            setup(()->

              model = new Backbone.Model()
              outModel = adder(model)
              handler = outModel.onModelUpdated
            )
            test("Sets created text using created moment", ()->
              handler(
                get:(key)->
                  if key is "created"
                    format:(pattern)->
                      "STRING FROM MOMENT: "+pattern)
              a.equal(outModel.get("createdText").substr(0,18),"STRING FROM MOMENT")
            )
            test("Sets Created as created moment", ()->
              handler(
                get:(key)->
                  if key is "created"
                    moment
              )
              a.equal(outModel.get("created"), moment)
            )

            test("Created isn't moment - uses placeholder", ()->
              handler(
                get:()->
                  "NOT_MOMENT"
              )
              a.isString(outModel.get("createdText"))
            )
            test("Created unavailable - uses placeholder", ()->
              handler(
                get:()->
                  undefined
              )
              a.isString(outModel.get("createdText"))
            )
            test("Copies label", ()->
             handler(
                get:(key)->
                  if key is "label" then return "MOCK_LABEL"
              )
              a.equal(outModel.get("label"), "MOCK_LABEL")
            )
            test("User status CHALLENGED - Sets Status Text", ()->
              handler(
                get:(key)->
                  if key is "userStatus" then return Constants.CHALLENGED_STATE
              )
              a.isString(outModel.get("statusText"))
            )
            test("User status READY - Sets status text", ()->
              handler(
                get:(key)->
                  if key is "userStatus" then return Constants.READY_STATE
              )
              a.isString(outModel.get("statusText"))
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
        suite("onRemove", ()->
          onremove = null
          setup(()->
            mocks["setTimeout"].func = jm.mockFunction()
            glvm = new GameListViewModel()
            glvm.updateFromWatchedCollections=jm.mockFunction()
            jm.when(glvm.updateFromWatchedCollections)(
              m.anything(),
              m.func(),
              m.anything(),
              m.anything()).then((a,b,c,d)->
              onremove = d
            )
            glvm.onSourceUpdated()
          )
          test("Unwatches item", ()->

            deleted =
              unwatch:jm.mockFunction()
            onremove(deleted)
            jm.verify(deleted.unwatch)()
          )
          test("No item - throws", ()->
            a.throw(()->onremove())
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
      test("Input matches id in list - triggers selectedGameChanged with id", ()->
        glvm.selectGame("MOCK_GAME_ID2")
        jm.verify(glvm.trigger)("selectedGameChanged","MOCK_GAME_ID2")
      )

      test("Input id not in list - triggers selectedGameChanged with nothing", ()->
        glvm.selectGame("NOT AN ID")
        jm.verify(glvm.trigger)("selectedGameChanged")
        jm.verify(glvm.trigger, v.never())("selectedGameChanged",m.anything())
      )

      test("No input - triggers selectedGameChanged with nothing", ()->
        glvm.selectGame()
        jm.verify(glvm.trigger)("selectedGameChanged")
        jm.verify(glvm.trigger, v.never())("selectedGameChanged",m.anything())
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

