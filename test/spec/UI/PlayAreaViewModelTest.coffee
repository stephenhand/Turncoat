updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      class ret
      ret
    )
  )
)

define(["isolate!UI/PlayAreaViewModel", "jsMockito", "jsHamcrest", "chai"], (PlayAreaViewModel, jm, h, c)->
  suite("PlayAreaViewModel", ()->
    m = h.Matchers
    a = c.assert
    v = jm.Verifiers
    mocks = mockLibrary["UI/PlayAreaViewModel"]
    overlays = null
    setup(()->
      overlays = new Backbone.Collection()
      mocks["UI/widgets/GameBoardViewModel"].prototype.get = (att)->
        if att is "overlays" then overlays
    )
    suite("initialise", ()->
      test("Creates new gameboard widget as 'gameBoard' attribute", ()->
        pavm = new PlayAreaViewModel()
        a.instanceOf(pavm.get("gameBoard"), mocks["UI/widgets/GameBoardViewModel"])
      )
      test("Options set without assetSelection - does not throw", ()->
        a.doesNotThrow(()->new PlayAreaViewModel({}))
      )
      test("Options set with invalid assetSelection - throws", ()->
        a.throw(()->new PlayAreaViewModel(null, assetSelectionView:{}))
      )
      suite("Valid assetSelectionView", ()->
        asv = null
        asvModel = null
        setup(()->
          asvModel = new Backbone.Model()
          asv = new Backbone.Model()
          asv.createModel = jm.mockFunction()
          jm.when(asv.createModel)().then(()->asv.model = asvModel)
        )
        test("Calls createModel on assetSelectionView", ()->
          new PlayAreaViewModel(null, assetSelectionView:asv)
          jm.verify(asv.createModel)()
        )
        test("Sets rootSelector on assetSelectionView to string", ()->
          new PlayAreaViewModel(null, assetSelectionView:asv)
          a.isString(asv.rootSelector)
        )
        test("Adds assetSelectionView model to overlays collection of gameboard", ()->
          new PlayAreaViewModel(null, assetSelectionView:asv)
          overlays.contains(asv.model)
        )
      )
    )
    suite("setGame", ()->
      pavm = null
      setup(()->
        pavm = new PlayAreaViewModel()
        pavm.get("gameBoard").setGame = jm.mockFunction()
      )
      test("Called with game - calls setGame on gameboard with game", ()->
        g = {}

        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").setGame)(g)
      )
      test("Called without game - calls setGame on gameboard with undefined", ()->
        g = {}
        pavm.setGame()
        jm.verify(pavm.get("gameBoard").setGame)(m.nil())
      )
    )
    suite("setGame", ()->
      pavm = null
      setup(()->
        pavm = new PlayAreaViewModel()
        pavm.get("gameBoard").setGame = jm.mockFunction()
      )
      test("Called with game - calls setGame on gameboard with game", ()->
        g = {}

        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").setGame)(g)
      )
      test("Called without game - calls setGame on gameboard with undefined", ()->
        g = {}
        pavm.setGame()
        jm.verify(pavm.get("gameBoard").setGame)(m.nil())
      )
    )
  )


)

