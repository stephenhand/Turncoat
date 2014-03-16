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
      Backbone.Model.extend(
        initialize:()->
          @watch=JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("UI/widgets/GameListViewModel","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:(m, opts)->
          @opts = opts
          @selectGame=JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("UI/widgets/PlayerListViewModel","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:(m, opts)->
          @watch = JsMockito.mockFunction()
          @unwatch=JsMockito.mockFunction()
          @on = JsMockito.mockFunction()
      )
    )
  )

)

define(["isolate!UI/administration/ReviewChallengesViewModel", "jsMockito", "jsHamcrest", "chai"], (ReviewChallengesViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/ReviewChallengesViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ReviewChallengesViewModel", ()->
    setup(()->
      mocks["UI/component/ObservingViewModelItem"].watch = jm.mockFunction()
      mocks["UI/component/ObservingViewModelItem"].unwatch = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].prototype.selectChallenge = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].watch = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].unwatch = jm.mockFunction()
    )
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].on = jm.mockFunction()
        mocks['AppState'].get = jm.mockFunction()
        mocks['AppState'].issueChallenge = jm.mockFunction()
        mocks['AppState'].acceptChallenge = jm.mockFunction()
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
      test("creates empty challengePlayerList as player list widget", ()->
        rcvm = new ReviewChallengesViewModel()
        a.instanceOf(rcvm.get("challengePlayerList"), mocks["UI/widgets/PlayerListViewModel"])
        a.equal(rcvm.get("challengePlayerList").length, 0)

      )
      test("Listens to challengePlayerList currentUserStatusUpdateEvent", ()->
        rcvm = new ReviewChallengesViewModel()
        jm.verify(rcvm.get("challengePlayerList").on)("currentUserStatusUpdate", m.func())

      )
      suite("challengePlayerList currentUserStatusChangedEvent listener", ()->
        listener = null
        rcvm = null
        setup(()->
          mocks["UI/widgets/PlayerListViewModel"].prototype.initialize=(mod, opts)->
            @watch = JsMockito.mockFunction()
            @unwatch=JsMockito.mockFunction()
            @on = JsMockito.mockFunction()
            jm.when(@on)("currentUserStatusUpdate", m.func()).then((n, l)->
              listener = l
            )
          rcvm = new ReviewChallengesViewModel()
        )
        test("Value provided - sets selectedChallengeUserStatus to value", ()->
          listener("A VALUE")
          a.equal(rcvm.get("selectedChallengeUserStatus"), "A VALUE")
        )
        test("Value not provided - unsets selectedChallengeUserStatus", ()->
          listener()
          a.isUndefined(rcvm.get("selectedChallengeUserStatus"))
        )

      )

      test("Creates challenges as gameList widget", ()->
        rcvm = new ReviewChallengesViewModel()
        a.instanceOf(rcvm.get("challenges"),  mocks["UI/widgets/GameListViewModel"])
      )
      test("creates challenges with filter specified", ()->
        rcvm = new ReviewChallengesViewModel()
        a.isFunction(rcvm.get("challenges").opts.filter)
      )
      suite("Challenges filter", ()->
        filter = null
        setup(()->
          filter = new ReviewChallengesViewModel().get("challenges").opts.filter
        )
        test("PLAYING UserStatus - returns false", ()->
          a.isFalse(filter(new Backbone.Model({userStatus:"PLAYING"})))
        )
        test("Missing UserStatus - returns false", ()->
          a.isFalse(filter(new Backbone.Model({})))

        )
        test("Other UserStatus - returns true", ()->
          a(filter(new Backbone.Model({userStatus:"ANYTHING_ELSE"})))
        )
        test("Invalid backbone model - throws", ()->
          a.throw(()->filter({userStatus:"ANYTHING_ELSE"}))
        )
      )
      test("Has Tab attribute - binds Tab ActiveChanged", ()->
        rcvm = new ReviewChallengesViewModel(
          tab:
            on:jm.mockFunction()
        )
        jm.verify(rcvm.get("tab").on)("change:active", m.func())
      )
      suite("tabActiveHandler", ()->
        rcvm = null
        mockGet = jm.mockFunction()
        mockOn = jm.mockFunction()
        handler = null
        setup(()->
          jm.when(mockOn)("change:active", m.func()).then((e, h)->handler = h)
          rcvm = new ReviewChallengesViewModel(
            tab:
              on:mockOn
              get:mockGet
          )
        )
        test("Tab becomes active - does nothing", ()->
          jm.when(mockGet)("active").then(()->true)
          handler(rcvm.get("tab"))
          jm.verify(rcvm.get("challenges").selectGame, v.never())()
        )
        test("Tab becomes inactive - unselects challenge", ()->
          jm.when(mockGet)("active").then(()->false)
          handler(rcvm.get("tab"))
          jm.verify(rcvm.get("challenges").selectGame)()
        )

        suite("Challenges selectedChallengeChanged Handler", ()->
          rcvm = undefined
          setup(()->
            mocks["AppState"].loadGame = jm.mockFunction()
            jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
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
            rcvm.set("selectedChallenge", get:()->)
          )
          suite("Valid Identifier", ()->
            setup(()->
            )
            test("Loads Game State Using Identifier", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
            )
            test("Sets selectedChallenge attribute to result", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              a.equal("GAME FROM ID: AN IDENTIFIER", rcvm.get("selectedChallenge").get("label"))
            )
            test("Unsets selectedChallenge attribute if result undefined", ()->
              jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->)
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              a.isUndefined(rcvm.get("selectedChallenge"))
            )
            test("challengePlayerList unwatches", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").unwatch)()
            )
            test("challengePlayerList watches challenge", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").watch)(rcvm.get("selectedChallenge"))

            )
          )
          suite("No identifier", ()->
            test("Unsets SelectedChallenge", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged")
              a.isUndefined(rcvm.get("selectedChallenge"))
            )
            test("challengePlayerList unwatches", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged")
              jm.verify(rcvm.get("challengePlayerList").unwatch)()
            )

          )
        )
      )
      suite("selectChallenge", ()->
        rcvm = null
        setup(()-> rcvm=new ReviewChallengesViewModel())
        test("Calls selectGame on challenges gameList", ()->
          rcvm.selectChallenge("A GAME ID")
          jm.verify(rcvm.get("challenges").selectGame)("A GAME ID")
        )
        test("Challenges not set - throws", ()->
          rcvm.unset("challenges")
          a.throw(()->rcvm.selectGame("A GAME ID"))
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
          jm.verify(mocks.AppState.issueChallenge)("ANOTHER USER", "SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.issueChallenge("ANOTHER USER")
          jm.verify(mocks.AppState.issueChallenge)("ANOTHER USER", m.nil())
        )
        test("No identifier - throws", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          a.throw(()->rcvm.issueChallenge())
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
          jm.verify(mocks.AppState.acceptChallenge)("SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.acceptChallenge()
          jm.verify(mocks.AppState.acceptChallenge)(m.nil())
        )
      )
    )
  )


)

