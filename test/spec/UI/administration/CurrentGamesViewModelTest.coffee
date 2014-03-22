require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameListViewModel","UI/administration/CurrentGamesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:(m, opts)->
          @opts = opts
          @selectGame=JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("UI/widgets/PlayerListViewModel","UI/administration/CurrentGamesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:(m, opts)->
          @watch = JsMockito.mockFunction()
          @unwatch=JsMockito.mockFunction()
          @on = JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("UI/routing/Router","UI/administration/CurrentGamesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      setRoute:()->
    )

  )
  Isolate.mapAsFactory("UI/routing/Route","UI/administration/CurrentGamesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        constructor:(route)->
          @route=route
      ret
    )

  )
  Isolate.mapAsFactory("AppState","UI/administration/CurrentGamesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      loadGame:()->
    )

  )
)

define(["isolate!UI/administration/CurrentGamesViewModel", "jsMockito", "jsHamcrest", "chai"], (CurrentGamesViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/CurrentGamesViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("CurrentGamesViewModel", ()->
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].on = jm.mockFunction()
        mocks['AppState'].get = jm.mockFunction()
        mocks['AppState'].issueChallenge = jm.mockFunction()
        mocks['AppState'].acceptChallenge = jm.mockFunction()
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
      test("Creates 'games' gameList widget", ()->
        cgvm = new CurrentGamesViewModel()
        a.instanceOf(cgvm.get("games"), mocks["UI/widgets/GameListViewModel"])
      )
      test("creates empty 'playerList' as player list widget", ()->
        cgvm = new CurrentGamesViewModel()
        a.instanceOf(cgvm.get("playerList"), mocks["UI/widgets/PlayerListViewModel"])
        a.equal(cgvm.get("playerList").length, 0)

      )
      test("Listens to challengePlayerList currentUserStatusUpdateEvent", ()->
        cgvm = new CurrentGamesViewModel()
        jm.verify(cgvm.get("playerList").on)("currentUserStatusUpdate", m.func())

      )
      suite("playerList currentUserStatusChangedEvent listener", ()->
        listener = null
        cgvm = null
        setup(()->
          mocks["UI/widgets/PlayerListViewModel"].prototype.initialize=(mod, opts)->
            @watch = JsMockito.mockFunction()
            @unwatch=JsMockito.mockFunction()
            @on = JsMockito.mockFunction()
            jm.when(@on)("currentUserStatusUpdate", m.func()).then((n, l)->
              listener = l
            )
          cgvm = new CurrentGamesViewModel()
        )
        test("Value provided - sets selectedChallengeUserStatus to value", ()->
          listener("A VALUE")
          a.equal(cgvm.get("selectedGameUserStatus"), "A VALUE")
        )
        test("Value not provided - unsets selectedGameUserStatus", ()->
          listener()
          a.isUndefined(cgvm.get("selectedGameUserStatus"))
        )

      )
    )
    suite("tabActiveHandler", ()->
      cgvm = null
      mockGet = jm.mockFunction()
      mockOn = jm.mockFunction()
      handler = null
      setup(()->
        jm.when(mockOn)("change:active", m.func()).then((e, h)->handler = h)
        cgvm = new CurrentGamesViewModel(
          tab:
            on:mockOn
            get:mockGet
        )
      )
      test("Tab becomes active - does nothing", ()->
        jm.when(mockGet)("active").then(()->true)
        handler(cgvm.get("tab"))
        jm.verify(cgvm.get("games").selectGame, v.never())()
      )
      test("Tab becomes inactive - unselects challenge", ()->
        jm.when(mockGet)("active").then(()->false)
        handler(cgvm.get("tab"))
        jm.verify(cgvm.get("games").selectGame)()
      )
    )
    suite("Games selectedGameChanged Handler", ()->
      cgvm = undefined
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
        cgvm = new CurrentGamesViewModel()
        cgvm.set("selectedGame", get:()->)
      )
      suite("Valid Identifier", ()->
        setup(()->
        )
        test("Loads Game State Using Identifier", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
        )
        test("Sets selectedChallenge attribute to result", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          a.equal("GAME FROM ID: AN IDENTIFIER", cgvm.get("selectedGame").get("label"))
        )
        test("Unsets selectedChallenge attribute if result undefined", ()->
          jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->)
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          a.isUndefined(cgvm.get("selectedGame"))
        )
        test("challengePlayerList unwatches", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(cgvm.get("playerList").unwatch)()
        )
        test("challengePlayerList watches challenge", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(cgvm.get("playerList").watch)(cgvm.get("selectedGame"))

        )
      )
      suite("No identifier", ()->
        test("Unsets selectedGame", ()->
          cgvm.get("games").trigger("selectedGameChanged")
          a.isUndefined(cgvm.get("selectedGame"))
        )
        test("challengePlayerList unwatches", ()->
          cgvm.get("games").trigger("selectedGameChanged")
          jm.verify(cgvm.get("playerList").unwatch)()
        )

      )
    )
    suite("selectGame", ()->
      cgvm = null
      setup(()-> cgvm=new CurrentGamesViewModel())
      test("Calls selectGame on  'games' gameList widget", ()->
        cgvm.selectGame("A GAME ID")
        jm.verify(cgvm.get("games").selectGame)("A GAME ID")
      )
      test("Games not set - throws", ()->
        cgvm.unset("games")
        a.throw(()->cgvm.selectGame("A GAME ID"))
      )
      test("creates games with filter specified", ()->
        cgvm = new CurrentGamesViewModel()
        a.isFunction(cgvm.get("games").opts.filter)
      )
      suite("Challenges filter", ()->
        filter = null
        setup(()->
          filter = new CurrentGamesViewModel().get("games").opts.filter
        )
        test("PLAYING UserStatus - returns true", ()->
          a(filter(new Backbone.Model({userStatus:"PLAYING"})))
        )
        test("Missing UserStatus - returns false", ()->
          a.isFalse(filter(new Backbone.Model({})))

        )
        test("Other UserStatus - returns false", ()->
          a.isFalse(filter(new Backbone.Model({userStatus:"ANYTHING_ELSE"})))
        )
        test("Invalid backbone model - throws", ()->
          a.throw(()->filter({userStatus:"ANYTHING_ELSE"}))
        )
      )
    )
    suite("launchGame", ()->
      router = mocks["UI/routing/Router"]
      cgvm = null
      setup(()->
        cgvm = new CurrentGamesViewModel()
        cgvm.set("selectedGame",new Backbone.Model(id:"A_GAME_ID"))
        jm.when(mocks['AppState'].get)("currentUser").then(()->
          new Backbone.Model(id:"A_USER_ID")
        )
        router.setRoute = jm.mockFunction()
      )
      test("Game selected and currentUser set in AppState - assigns location path using currentUser id and selectedGame id", ()->
        cgvm.launchGame()
        jm.verify(router.setRoute)(m.hasMember("route",m.endsWith("A_USER_ID/A_GAME_ID")))
      )
      test("currentUser not set in AppState - throws", ()->
        jm.when(mocks['AppState'].get)(m.anything()).then(()->)
        a.throw(()=>cgvm.launchGame())
      )
      test("currentUser not set in AppState - throws", ()->
        cgvm.unset("selectedGame")
        a.throw(()=>cgvm.launchGame())
      )
    )
  )


)

