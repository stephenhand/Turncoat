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
)

define(["isolate!UI/administration/CurrentGamesViewModel", "jsMockito", "jsHamcrest", "chai"], (CurrentGamesViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/CurrentGamesViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("CurrentGamesViewModel", ()->
    suite("initialize", ()->

      test("Creates 'games' gameList widget", ()->
        cgvm = new CurrentGamesViewModel()
        a.instanceOf(cgvm.get("games"), mocks["UI/widgets/GameListViewModel"])
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
  )


)

