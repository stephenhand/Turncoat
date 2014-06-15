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
  Isolate.mapAsFactory("AppState","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      new Backbone.Model(
        currentUser:new Backbone.Model(id:"MOCK_CURRENT_USER")
      )
    )
  )
)

define(["isolate!UI/PlayAreaViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers", ], (PlayAreaViewModel, m, o, a, jm, v)->
  suite("PlayAreaViewModel", ()->
    ASSETSELECTIONVIEW = "assetSelectionView"
    ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"

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
        a(pavm.get("gameBoard"), m.instanceOf(mocks["UI/widgets/GameBoardViewModel"]))
      )
    )
    suite("setViewAPI", ()->
      test("Called with parameter with requestOverlay method - does not throw", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI(
              requestOverlay:()->
            )
        ,
          m.not(m.raisesAnything())
        )
      )
      test("Called with parameter with non callable requerstOverlay property - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI(
              requestOverlay:{}
            )
        ,
          m.raisesAnything()
        )
      )
      test("Called with parameter without requestOverlay property - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI({})
        ,
          m.raisesAnything()
        )
      )
      test("Called without parameter - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI()
        ,
          m.raisesAnything()
        )
      )
    )
    suite("setGame", ()->
      g = null
      pavm = null
      setup(()->
        g =
          getCurrentControllingUser:jm.mockFunction()
        jm.when(g.getCurrentControllingUser)().then(()->
          new Backbone.Model(id:"MOCK_CURRENT_USER")
        )
        pavm = new PlayAreaViewModel()
        pavm.get("gameBoard").setGame = jm.mockFunction()
        pavm.get("gameBoard").set("overlays",add:jm.mockFunction())
        pavm.get("gameBoard").set("underlays",add:jm.mockFunction())
      )
      test("Called with game - calls setGame on gameboard with game", ()->
        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").setGame)(g)
      )
      test("Current player is controlling player - adds model to underlays with ASSETSELECTIONVIEW as id", ()->
        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").get("underlays").add)(m.hasMember("id", ASSETSELECTIONVIEW))
      )
      test("Current player is controlling player, view api set - calls requestOverlay with game, ASSETSELECTIONVIEW as id and underlays as layer", ()->
        api =
          requestOverlay:jm.mockFunction()
        pavm.setViewAPI(api)
        pavm.setGame(g)
        jm.verify(api.requestOverlay)(
          m.allOf(
            m.hasMember("id", ASSETSELECTIONVIEW),
            m.hasMember("gameData", g),
            m.hasMember("layer", "underlays")
          )
        )
      )
      test("Current player is controlling player - adds model to overlays with ASSETSELECTIONHOTSPOTS as id", ()->
        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").get("overlays").add)(m.hasMember("id", ASSETSELECTIONHOTSPOTS))
      )
      test("Current player is controlling player, view api set - calls requestOverlay with game, ASSETSELECTIONHOTSPOTS as id and overlays as layer", ()->
        api =
          requestOverlay:jm.mockFunction()
        pavm.setViewAPI(api)
        pavm.setGame(g)
        jm.verify(api.requestOverlay)(
          m.allOf(
            m.hasMember("id", ASSETSELECTIONHOTSPOTS),
            m.hasMember("gameData", g),
            m.hasMember("layer", "overlays")
          )
        )
      )
      test("Current player is not controlling player - adds and requests no overlays", ()->
        api =
          requestOverlay:jm.mockFunction()
        jm.when(g.getCurrentControllingUser)().then(()->
          new Backbone.Model(id:"NOT MOCK_CURRENT_USER")
        )
        pavm.setViewAPI(api)
        pavm.setGame(g)
        jm.verify(api.requestOverlay, v.never())(
          m.anything()
        )
        jm.verify(pavm.get("gameBoard").get("underlays").add, v.never())(m.anything())
        jm.verify(pavm.get("gameBoard").get("overlays").add, v.never())(m.anything())
      )
      test("Called without game - calls setGame on gameboard with undefined", ()->
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
        a(pavm.get("gameBoard").get("overlays").length, 0)
        pavm.setGame(
          getCurrentControllingUser:()->
            get:()->
        )
        pavm.setGame()
        pavm.activateOverlay("AN ID")
        a(pavm.get("gameBoard").get("overlays").length, 0)

      )
      suite("Called when game set", ()->
        api=null
        g=
          getCurrentControllingUser:()->
            get:()->
        setup(()->
          api =
            requestOverlay:jm.mockFunction()
          pavm.setViewAPI(api)
          pavm.setGame(g)
        )
        test("Creates a model in overlays with specified id on collection at attribute specified by layer", ()->
          pavm.activateOverlay("AN ID","MOCK LAYER")
          a(pavm.get("gameBoard").get("MOCK LAYER").length, 1)
          a(pavm.get("gameBoard").get("MOCK LAYER").at(0).get("id"), "AN ID")
        )
        test("calls requestOverlay on the current view api with id and game model", ()->
          pavm.trigger = jm.mockFunction()
          pavm.activateOverlay("AN ID", "MOCK LAYER")
          jm.verify(api.requestOverlay)(m.allOf(
            m.hasMember("id","AN ID"),
            m.hasMember("gameData",g)
          ))
        )
        test("Layer attribute not set - throws error", ()->
          pavm.get("gameBoard").unset("MOCK LAYER")
          a(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          ,
            m.raisesAnything()
          )
        )
        test("Layer attribute not valid bb collection - throws", ()->
          pavm.get("gameBoard").set("MOCK LAYER", {})
          a(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          ,
            m.raisesAnything()
          )
        )
      )
    )
  )


)

