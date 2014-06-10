updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      ret=Backbone.Model.extend(
        initialize:()->
          @set("overlays", new Backbone.Collection())
          @set("MOCK LAYER", new Backbone.Collection())
        setGame:()->
      )
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
      origGet = null
      overlays = null
      setup(()->
        overlays = new Backbone.Collection()
        underlays = new Backbone.Collection()
        origGet = mocks["UI/widgets/GameBoardViewModel"].prototype.get
        mocks["UI/widgets/GameBoardViewModel"].prototype.get = (att)->
          if att is "overlays" then overlays
          if att is "underlays" then underlays
      )
      teardown(()->
        mocks["UI/widgets/GameBoardViewModel"].prototype.get = origGet
      )
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
    suite("activateOverlay", ()->
      pavm = null
      setup(()->
        pavm = new PlayAreaViewModel()
      )
      test("Called without game - does nothing", ()->
        pavm.activateOverlay("AN ID")
        a.lengthOf(pavm.get("gameBoard").get("overlays"), 0)
        pavm.setGame({})
        pavm.setGame()
        pavm.activateOverlay("AN ID")
        a.lengthOf(pavm.get("gameBoard").get("overlays"), 0)

      )
      suite("Called when game set", ()->
        g={}
        setup(()->
          pavm.setGame(g)
        )
        test("Creates a model in overlays with specified id on collection at attribute specified by layer", ()->
          pavm.activateOverlay("AN ID","MOCK LAYER")
          a.equal(pavm.get("gameBoard").get("MOCK LAYER").length, 1)
          a.equal(pavm.get("gameBoard").get("MOCK LAYER").at(0).get("id"), "AN ID")
        )
        test("Triggers 'overlayRequest' event with id and game model", ()->
          pavm.trigger = jm.mockFunction()
          pavm.activateOverlay("AN ID", "MOCK LAYER")
          jm.verify(pavm.trigger)("overlayRequest",m.allOf(
            m.hasMember("id","AN ID"),
            m.hasMember("gameData",g)
          ))
        )
        test("Layer attribute not set - throws error", ()->
          pavm.get("gameBoard").unset("MOCK LAYER")
          a.throws(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          )
        )
        test("Layer attribute not valid bb collection - throws", ()->
          pavm.get("gameBoard").set("MOCK LAYER", {})
          a.throws(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          )
        )
      )
    )
  )


)

