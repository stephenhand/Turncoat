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
    suite("initialise", ()->
      test("Creates new gameboard widget as 'gameBoard' attribute", ()->
        pavm = new PlayAreaViewModel()
        a.instanceOf(pavm.get("gameBoard"), mocks["UI/widgets/GameBoardViewModel"])
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

