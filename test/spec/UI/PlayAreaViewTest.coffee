updateFromWatchedCollectionsRes=null

ASSETSELECTIONVIEW = "assetSelectionView"
ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      loadGame:(id)->
    )
  )
  Isolate.mapAsFactory("UI/PlayAreaViewModel","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        constructor:(model, opts)->
          @constructedWith=model
          @constructedWithOpts=opts
          @setGame=()->
          @on=JsMockito.mockFunction()
          @get=JsMockito.mockFunction()
      ret
    )
  )
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayView","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=JsMockito.mockFunction()
      ret::set=JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("UI/board/AssetSelectionUnderlayView","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=JsMockito.mockFunction()
      ret::set=JsMockito.mockFunction()

    )
  )
)

define(["isolate!UI/PlayAreaView", "matchers", "operators", "assertThat","jsMockito", "verifiers", ], (PlayAreaView, m, o, a, jm, v)->
  suite("PlayAreaView", ()->
    mocks = mockLibrary["UI/PlayAreaView"]
    suite("createModel", ()->

      test("Sets Model as new PlayAreaViewModel without model parameter", ()->

        pav = new PlayAreaView(gameState:{})

        pav.createModel()
        a(m.not(m.nil(pav.model)))
        a(m.not(pav.model.constructedWith?))
      )
      test("Binds to model's overlayRequest event", ()->
        pav = new PlayAreaView(gameState:{})
        pav.createModel()
        jm.verify(pav.model.on)("overlayRequest", m.func(), pav)
      )
      suite("overlayRequest handler", ()->
        pav = null
        handler = null
        overlays = null
        underlays = null
        setup(()->
          pav = new PlayAreaView(gameState:{})
          pav.createModel()
          mockLayerCollection =
            set:jm.mockFunction()
          jm.when(pav.model.get)("gameBoard").then(()->
            get:(key)->
              if key is "MOCK_LAYER"
                mockLayerCollection
          )
          jm.verify(pav.model.on)("overlayRequest",
            new JsHamcrest.SimpleMatcher(
              matches:(h)=>
                try
                  handler=h
                  true
                catch
                  false
            )
          , pav)

          overlays = []
          underlays=[]
          jm.when(mocks["UI/board/AssetSelectionUnderlayView"])().then(()->
            @set = jm.mockFunction()
            @createModel = jm.mockFunction()
            jm.when(@createModel)().then(()=>
              @model =
                setGame:jm.mockFunction()
                set:jm.mockFunction()
            )
            underlays.push(@)
            @
          )
          jm.when(mocks["UI/board/AssetSelectionOverlayView"])().then(()->
            @set = jm.mockFunction()
            @createModel = jm.mockFunction()
            jm.when(@createModel)().then(()=>
              @model =
                setGame:jm.mockFunction()
                set:jm.mockFunction()
            )
            overlays.push(@)
            @
          )
        )
        test("ID specifies assetSelectionView - creates assetSelectionUnderlayView", ()->
          handler.call(pav,
            id:ASSETSELECTIONVIEW
            gameData:{}
            layer:"MOCK_LAYER"
          )
          a(underlays.length, 1)
          a(overlays, m.empty())
        )
        test("ID specifies assetSelectionHotspots - creates assetSelectionOverlayView", ()->
          handler.call(pav,
            id:ASSETSELECTIONHOTSPOTS
            gameData:{}
            layer:"MOCK_LAYER"
          )
          a(overlays.length, 1)
          a(underlays, m.empty())
        )
        test("Calls new view's createModel method", ()->
          handler.call(pav,
            id:ASSETSELECTIONHOTSPOTS
            gameData:{}
            layer:"MOCK_LAYER"
          )
          jm.verify(overlays[0].createModel)()
        )
        test("Sets new view's model to game supplied in request", ()->
          g = {}
          handler.call(pav,
            id:ASSETSELECTIONHOTSPOTS
            gameData:g
            layer:"MOCK_LAYER"
          )
          jm.verify(overlays[0].model.setGame)(g)
        )
        test("A collection exists on attribute of current view's model's gameboard specified by request layer - adds new view's model to it using set without remove option", ()->
          handler.call(pav,
            id:ASSETSELECTIONHOTSPOTS
            gameData:{}
            layer:"MOCK_LAYER"
          )
          jm.verify(pav.model.get("gameBoard").get("MOCK_LAYER").set)(
            m.equivalentArray([overlays[0].model]),
            m.hasMember("remove",false)
          )
        )
        test("Attribute of current view's model's gameboard matching request layer is not a backbone collection - throws", ()->
          jm.when(pav.model.get)("gameBoard").then(()->
            get:(key)->
              if key is "MOCK_LAYER"
                {}
          )
          a(()->
            handler.call(pav,
              id:ASSETSELECTIONHOTSPOTS
              gameData:{}
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
        test("No attribute of current view's model's gameboard matching request layer exists - throws", ()->
          jm.when(pav.model.get)("gameBoard").then(()->
            get:(key)->
          )

          a(()->
            handler.call(pav,
              id:ASSETSELECTIONHOTSPOTS
              gameData:{}
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
        test("No gameboard attribute of current view's model exists - throws", ()->
          jm.when(pav.model.get)("gameBoard").then(()->)

          a(()->
            handler.call(pav,
              id:ASSETSELECTIONHOTSPOTS
              gameData:{}
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
        test("Invalid ID specified - throws", ()->
          a(()->
            handler.call(pav,
              id:"AMOTHER ID"
              gameData:{}
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
        test("No ID specified - throws", ()->
          a(()->
            handler.call(pav,
              gameData:{}
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
        test("No layer specified - throws", ()->
          a(()->
            handler.call(pav,
              id:ASSETSELECTIONHOTSPOTS
              gameData:{}
            )
          , m.raisesAnything())
        )
        test("No game specified - throws", ()->
          a(()->
            handler.call(pav,
              id:ASSETSELECTIONHOTSPOTS
              layer:"MOCK_LAYER"
            )
          , m.raisesAnything())
        )
      )
    )
    suite("routeChanged", ()->
      pav = null
      setup(()->
        mocks["AppState"].loadGame = jm.mockFunction()
        jm.when(mocks["AppState"].loadGame)(m.anything()).then((id)->
          loadedGameId:id
        )
        pav = new PlayAreaView(gameState:{})
        pav.createModel()
        pav.model.setGame = jm.mockFunction()
      )
      test("Route has 2 parts - uses 2nd part as identifier to load game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ])
        jm.verify(mocks["AppState"].loadGame)("PART 2")
      )
      test("Route has 2 parts - sets game with loaded game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ])
        jm.verify(pav.model.setGame)(m.hasMember("loadedGameId","PART 2"))
      )
      test("Route has more than 2 parts - sets game with loaded game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ,
          "PART 3"
        ,
          "PART 4"
        ])
        jm.verify(pav.model.setGame)(m.hasMember("loadedGameId","PART 2"))
      )
      test("Route has less than 2 parts - unsets game", ()->
        pav.routeChanged(parts:["PART 1"])
        jm.verify(pav.model.setGame)()
      )
      test("Route has parts not defined - unsets game", ()->
        pav.routeChanged(parts:["PART 1"])
        jm.verify(pav.model.setGame)()
      )
      test("Route not set - throws", ()->
        a(
          ()=>pav.routeChanged()
        ,
          m.raisesAnything()
        )
      )
    )
  )


)

