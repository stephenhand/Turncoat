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
        jm.when(mocks["AppState"].get)(m.anything()).then((att)->
          if att is "currentUser" then new Backbone.Model(id:"CURRENT USER")
        )
        mocks["AppState"].loadGame = jm.mockFunction()
        jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
          ret = new Backbone.Model(
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
          ret.getCurrentControllingUser=jm.mockFunction()
          jm.when(ret.getCurrentControllingUser)().then(()->get:()->)
          ret
        )
        cgvm = new CurrentGamesViewModel()
        cgvm.set("selectedGame",
          get:(att)->
          off:jm.mockFunction()
        )
        cgvm.stopListening = jm.mockFunction()
      )
      suite("Valid Identifier", ()->
        setup(()->
          cgvm.listenTo = jm.mockFunction()
        )
        test("Loads Game State Using Identifier", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
        )
        test("Sets selectedGame attribute to result", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          a.equal("GAME FROM ID: AN IDENTIFIER", cgvm.get("selectedGame").get("label"))
        )
        test("Games getCurrentControllingUser returns user with id of current user - Sets isControlling attribute to true", ()->
          jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
            ret = new Backbone.Model(
              label:"GAME FROM ID: "+a
              players:new Backbone.Collection([])
              users:new Backbone.Collection([])
            )
            ret.getCurrentControllingUser=jm.mockFunction()
            jm.when(ret.getCurrentControllingUser)().then(()->new Backbone.Model(id:"CURRENT USER"))
            ret
          )
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          a.isTrue(cgvm.get("isCurrentUserControlling"))
        )
        test("Games getCurrentControllingUser returns user with id other than that of current user - Sets isControlling attribute to false", ()->
          jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
            ret = new Backbone.Model(
              label:"GAME FROM ID: "+a
              players:new Backbone.Collection([])
              users:new Backbone.Collection([])

            )
            ret.getCurrentControllingUser=jm.mockFunction()
            jm.when(ret.getCurrentControllingUser)().then(()->new Backbone.Model(id:"NOT CURRENT USER"))
            ret
          )
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          a.isFalse( cgvm.get("isCurrentUserControlling"))
        )
        test("Games getCurrentControllingUser returns object without get function - throws", ()->
          jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
            ret = new Backbone.Model(
              label:"GAME FROM ID: "+a
              players:new Backbone.Collection([])
              users:new Backbone.Collection([])

            )
            ret.getCurrentControllingUser=jm.mockFunction()
            jm.when(ret.getCurrentControllingUser)().then(()->{})
            ret
          )
          a.throw(()->cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER"))
        )
        test("Games getCurrentControllingUser returns nothing - throws", ()->
          jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
            ret = new Backbone.Model(
              label:"GAME FROM ID: "+a
              players:new Backbone.Collection([])
              users:new Backbone.Collection([])

            )
            ret.getCurrentControllingUser=jm.mockFunction()
            jm.when(ret.getCurrentControllingUser)().then(()->)
            ret
          )
          a.throw(()->cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER"))
        )
        test("Already has game selected - stops listening to that games 'movesUpdated' event.", ()->
          cgvm.stopListening = jm.mockFunction()
          g = cgvm.get("selectedGame")
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(cgvm.stopListening)(g, "movesUpdated")
        )
        test("No game already selected - stops listening to nothing.", ()->
          cgvm.unset("selectedGame")
          ()->cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(cgvm.stopListening, v.never())(m.anything(), "movesUpdated")
        )
        test("Unsets selectedGame attribute if result undefined", ()->
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
        test("Listens to new selected game's 'movesUpdated' event", ()->
          cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
          jm.verify(cgvm.listenTo)(cgvm.get("selectedGame"), "movesUpdated", m.func())
        )
        suite("'movesUpdated' listener", ()->
          listener = null
          selectedGame = null
          setup(()->
            selectedGame = new Backbone.Model(
              label:"GAME FROM ID: "+a
              players:new Backbone.Collection([])
              users:new Backbone.Collection([])
            )
            selectedGame.getCurrentControllingUser=jm.mockFunction()
            jm.when(selectedGame.getCurrentControllingUser)().then(()->new Backbone.Model(id:"CURRENT USER"))
            jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
              selectedGame
            )
            jm.when(cgvm.listenTo)(m.anything(), "movesUpdated", m.func()).then((o, e, l)->
              listener = l
            )
            cgvm.get("games").trigger("selectedGameChanged", "AN IDENTIFIER")
            cgvm.unset("isCurrentUserControlling")
          )
          test("Games getCurrentControllingUser returns user with id of current user - Sets isControlling attribute to true", ()->
            jm.when(selectedGame.getCurrentControllingUser)().then(()->new Backbone.Model(id:"CURRENT USER"))
            listener()
            a.isTrue(cgvm.get("isCurrentUserControlling"))
          )
          test("Games getCurrentControllingUser returns user with id other than that of current user - Sets isControlling attribute to false", ()->
            jm.when(selectedGame.getCurrentControllingUser)().then(()->new Backbone.Model(id:"NOT CURRENT USER"))
            listener()
            a.isFalse( cgvm.get("isCurrentUserControlling"))
          )
          test("Games getCurrentControllingUser returns object without get function - throws", ()->
            jm.when(selectedGame.getCurrentControllingUser)().then(()->{})
            a.throw(()->listener())
          )
          test("Games getCurrentControllingUser returns nothing - throws", ()->
            jm.when(selectedGame.getCurrentControllingUser)().then(()->)
            a.throw(()->listener())
          )
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
        test("Already has game selected - stops listening to that games 'movesUpdated' event.", ()->
          cgvm.stopListening = jm.mockFunction()
          g = cgvm.get("selectedGame")
          cgvm.get("games").trigger("selectedGameChanged")
          jm.verify(cgvm.stopListening)(g, "movesUpdated")
        )
        test("No game already selected - stops listening to nothing.", ()->
          cgvm.stopListening = jm.mockFunction()
          cgvm.unset("selectedGame")
          ()->cgvm.get("games").trigger("selectedGameChanged")
          jm.verify(cgvm.stopListening, v.never())(m.anything(), "movesUpdated")
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
      suite("Games filter", ()->
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

