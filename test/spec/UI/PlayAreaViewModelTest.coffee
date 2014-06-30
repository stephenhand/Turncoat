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
    ASSETCOMMANDVIEW = "assetCommandView"

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
      mockUnderlayModel = null
      setup(()->

        mockUnderlayModel =
          on:jm.mockFunction()
          get:jm.mockFunction()
        g =
          getCurrentControllingUser:jm.mockFunction()
        jm.when(g.getCurrentControllingUser)().then(()->
          new Backbone.Model(id:"MOCK_CURRENT_USER")
        )
        pavm = new PlayAreaViewModel()
        pavm.get("gameBoard").setGame = jm.mockFunction()
        getter = jm.mockFunction()
        pavm.get("gameBoard").set("overlays",add:jm.mockFunction())
        pavm.get("gameBoard").set("underlays",
          add:jm.mockFunction()
          get:getter
        )
        jm.when(getter)(ASSETSELECTIONVIEW).then((vw)->
          get:(x)->
             if x is "overlayModel" then mockUnderlayModel
        );
      )
      test("Called with game - calls setGame on gameboard with game", ()->
        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").setGame)(g)
      )
      suite("Current player is controlling player", ()->
        test("Adds model to underlays with ASSETSELECTIONVIEW as id", ()->
          pavm.setGame(g)
          jm.verify(pavm.get("gameBoard").get("underlays").add)(m.hasMember("id", ASSETSELECTIONVIEW))
        )
        test("Adds model to overlays with ASSETSELECTIONHOTSPOTS as id", ()->
          pavm.setGame(g)
          jm.verify(pavm.get("gameBoard").get("overlays").add)(m.hasMember("id", ASSETSELECTIONHOTSPOTS))
        )
        test("Activating underlay fails to create desired layer structure - throws", ()->
          getter = jm.mockFunction()
          pavm.get("gameBoard").set("underlays",
            add:jm.mockFunction()
            get:getter
          )
          jm.when(getter)(ASSETSELECTIONVIEW).then((vw)->
            get:(x)->
          );
          a(()->
            pavm.setGame(g)
          ,m.raisesAnything())
        )
        suite("View API is set", ()->
          api = null
          setup(()->
            api =
              requestOverlay:jm.mockFunction()
            pavm.setViewAPI(api)

          )
          test("Calls requestOverlay with game, ASSETSELECTIONVIEW as id and underlays as layer", ()->
            pavm.setGame(g)
            jm.verify(api.requestOverlay)(
              m.allOf(
                m.hasMember("id", ASSETSELECTIONVIEW),
                m.hasMember("gameData", g),
                m.hasMember("layer", "underlays")
              )
            )
          )
          test("Calls requestOverlay with game, ASSETSELECTIONHOTSPOTS as id, overlays as layer and overlayModel just added to underlays as model", ()->
            pavm.setGame(g)
            jm.verify(api.requestOverlay)(
              m.allOf(
                m.hasMember("id", ASSETSELECTIONHOTSPOTS),
                m.hasMember("gameData", g),
                m.hasMember("layer", "overlays")   ,
                m.hasMember("overlayModel", mockUnderlayModel)
              )
            )
          )
          test("Listens to the overlay/underlay model for changes to nominatedAsset", ()->
            pavm.setGame(g)
            jm.verify(mockUnderlayModel.on)("change:nominatedAsset", m.func(), pavm)
          )
          suite("overlay/underlay change:nominatedAsset listener",()->
            listener = null
            nominated = null
            setup(()->
              nominated = {}
              jm.when(mockUnderlayModel.get)("nominatedAsset").then(()->nominated)
              jm.when(mockUnderlayModel.on)("change:nominatedAsset", m.func(), pavm).then((e,l,c)->
                listener=l
              )
              pavm.setGame(g)
              pavm.activateOverlay = jm.mockFunction()
            )
            test("Activates command overlay with nominatedAsset",()->
              listener.call(pavm)
              jm.verify(pavm.activateOverlay)(ASSETCOMMANDVIEW,"overlays")
            )
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
        test("Model specified - passes this to request as overlayModel property", ()->
          om = {}
          pavm.trigger = jm.mockFunction()
          pavm.activateOverlay("AN ID", "MOCK LAYER",om)
          jm.verify(api.requestOverlay)(m.hasMember("overlayModel",om))
        )
      )
    )
  )


)

