require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/board/AssetCommandOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          @setGameMock = JsMockito.mockFunction()
          @initializeMock = JsMockito.mockFunction()
          super()
        setGame:(game)->
          @setGameMock(game)
        initialize:()->
          @initializeMock()
      ret
    )
  )
)

define(["isolate!UI/board/AssetCommandOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone"], (AssetCommandOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/AssetCommandOverlayViewModel"]
  suite("AssetCommandOverlayViewModel", ()->
    suite("initialize", ()->
      test("calls GameBoardViewModel initialize", ()->
        acovm = new AssetCommandOverlayViewModel()
        jm.verify(acovm.initializeMock)()
      )
      test("sets nominatedAssets as empty collection", ()->
        a(new AssetCommandOverlayViewModel().get("nominatedAssets"), m.allOf(m.instanceOf(Backbone.Collection), m.hasMember("models", m.empty())))
      )
    )
    suite("setGame", ()->
      test("calls GameBoardViewModel setGame with game", ()->
        g = {}
        acovm = new AssetCommandOverlayViewModel()
        acovm.setGame(g)
        jm.verify(acovm.setGameMock)(g)
      )

      test("game set - sets getCommandsForAsset to function", ()->
        acovm = new AssetCommandOverlayViewModel()
        acovm.setGame({})
        a(acovm.getCommandsForAsset, m.func())
      )
      test("game not set - deletes getCommandsForAsset", ()->
        acovm = new AssetCommandOverlayViewModel()
        acovm.getCommandsForAsset = ()->
        acovm.setGame()
        a(acovm, m.not(m.hasMember('getCommandsForAsset')))
      )
    )
    suite("setAsset", ()->
      suite("has valid ships collection", ()->
        acovm = null
        setup(()->
          acovm = new AssetCommandOverlayViewModel()
          acovm.set("ships",
            new Backbone.Collection([
              modelId:"MODEL 1"
            ,
              modelId:"MODEL 2"
            ,
              modelId:"MODEL 3"
            ])
          )


        )
        suite("called with id matching modeld of ship in collection", ()->
          test("Game not set - throws", ()->
            a(()->
              acovm.setAsset("MODEL 2")
            , m.raisesAnything())
          )
          suite("Game set", ()->
            g = null
            fleet = null
            setup(()->
              fleet = new Backbone.Collection([
                new Backbone.Model(
                  id:"MODEL 2"
                )
              ])
              acovm.setGame(
                g =
                  getCurrentControllingPlayer:()->
                    ret =new Backbone.Model(
                      fleet:fleet
                    )
                    ret.get("fleet").at(0).getAvailableActions=jm.mockFunction()
                    jm.when(ret.get("fleet").at(0).getAvailableActions)().then(()->
                      []
                    )
                    ret
              )
            )
            test("any part of property chain game.getCurrentControllingPlayer().get('fleet') missing - throws", ()->
              fleet.reset()
              a(()->
                acovm.setAsset("MODEL 2")
              , m.raisesAnything())
            )

            test("adds ship to nominated assets collection", ()->
              acovm.setAsset("MODEL 2")
              a(acovm.get("nominatedAssets").models, m.equivalentArray([acovm.get("ships").at(1)]))
            )
            test("removes anything already nominated assets collection", ()->
              acovm.set("nominatedAssets", new Backbone.Collection([
                "OTHER"
              ,
                "STUFF"
              ]))
              acovm.setAsset("MODEL 2")
              a(acovm.get("nominatedAssets").models, m.equivalentArray([acovm.get("ships").at(1)]))
            )
            suite("Valid game, model ship, viewmodel ship and actions", ()->
              modelShip = null
              setup(()->
                modelShip = new Backbone.Model(
                  id:"MODEL 2"
                )
                modelShip.getAvailableActions=jm.mockFunction()
                jm.when(modelShip.getAvailableActions)().then(()->
                  [
                    new Backbone.Model(name:"ACTION1")
                  ,
                    new Backbone.Model(name:"ACTION2")
                  ,
                    new Backbone.Model(name:"ACTION3")
                  ]
                )
                g =
                  getCurrentControllingPlayer:()->
                    new Backbone.Model(
                      fleet:new Backbone.Collection([
                        modelShip
                      ])
                    )
                acovm.setGame(g)
              )
              test("Retrieves command data from getAvailableAssets on model ship", ()->
                acovm.setAsset("MODEL 2")
                jm.verify(modelShip.getAvailableActions)()
              )
              test("Array of models returned - adds a command with label and same as action name and viewModel ship as target for all commands", ()->
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), "ACTION1")
                a(acovm.get("commands").at(0).get("name"), "ACTION1")
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
                a(acovm.get("commands").at(1).get("label"), "ACTION2")
                a(acovm.get("commands").at(1).get("name"), "ACTION2")
                a(acovm.get("commands").at(1).get("target"), acovm.get("ships").at(1))
                a(acovm.get("commands").at(2).get("label"), "ACTION3")
                a(acovm.get("commands").at(2).get("name"), "ACTION3")
                a(acovm.get("commands").at(2).get("target"), acovm.get("ships").at(1))
              )
              test("Empty array returned - adds nothing to commands", ()->
                jm.when(modelShip.getAvailableActions)().then(()->
                  []
                )
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").models, m.empty())
              )
              test("Invalid array returned - throws", ()->
                jm.when(modelShip.getAvailableActions)().then(()->
                  "INVALID"
                )
                a(()->
                  acovm.setAsset("MODEL 2")
                ,m.raisesAnything())
              )
              test("Invalid array items returned - throws", ()->
                jm.when(modelShip.getAvailableActions)().then(()->
                  [
                    new Backbone.Model(name:"ACTION1")
                  ,
                    "INVALIDNESS"
                  ]
                )
                a(()->
                  acovm.setAsset("MODEL 2")
                ,m.raisesAnything())
              )
              test("Nothing returned - throws", ()->
                jm.when(modelShip.getAvailableActions)().then(()->)
                a(()->
                  acovm.setAsset("MODEL 2")
                ,m.raisesAnything())
              )
            )
          )
        )
        test("called with id not matching modelId in ships collection - throws", ()->
          a(()->
            acovm.setAsset("CHEESE")
          ,
            m.raisesAnything()
          )
        )
        test("called with nothing - empties nominatedAssets", ()->
          acovm.set("nominatedAssets", new Backbone.Collection([
            "OTHER"
          ,
            "STUFF"
          ]))
          acovm.setAsset()
          a(acovm.get("nominatedAssets"),m.hasMember("models", m.empty()))
        )
      )
      test("Has invalid ships collection - throws", ()->
        a(()->
          acovm.set("ships",[])
          acovm.setAsset("CHEESE")
        ,
          m.raisesAnything()
        )
      )
      test("Has no ships collection - throws", ()->
        a(()->
          acovm.unset("ships")
          acovm.setAsset("CHEESE")
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

