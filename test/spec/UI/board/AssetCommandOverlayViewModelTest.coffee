require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NominatedAssetOverlayViewModel","UI/board/AssetCommandOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          @setGameSuper = JsMockito.mockFunction()
          @initializeSuper = JsMockito.mockFunction()
          @setAssetSuper = JsMockito.mockFunction()
          super()
        setGame:(game)->
          @setGameSuper(game)
        initialize:()->
          @set("nominatedAssets", new Backbone.Collection())
          @initializeSuper()
        setAsset:(id)->
          @setAssetSuper(id)
      ret
    )
  )
)

define(["isolate!UI/board/AssetCommandOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone"], (AssetCommandOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/AssetCommandOverlayViewModel"]
  suite("AssetCommandOverlayViewModel", ()->
    acovm = null
    suite("initialize", ()->
      test("calls NominatedAssetOverlayViewModel initialize", ()->
        acovm = new AssetCommandOverlayViewModel()
        jm.verify(acovm.initializeSuper)()
      )
    )
    suite("setGame", ()->
      test("calls NominatedAssetOverlayViewModel setGame with game", ()->
        g = {}
        acovm = new AssetCommandOverlayViewModel()
        acovm.setGame(g)
        jm.verify(acovm.setGameSuper)(g)
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
      test("Game not set - throws", ()->
        a(()->
          acovm.setAsset("MODEL 2")
        , m.raisesAnything())
      )
      suite("Valid game, model ship and nominated view ship", ()->
        modelShip = null
        fleet = null
        setup(()->
          modelShip = new Backbone.Model(
            id:"MODEL 2"
          )
          modelShip.getAvailableActions=jm.mockFunction()
          jm.when(modelShip.getAvailableActions)().then(()->
            [
              new Backbone.Model(name:"ACTION1")
            ,
              new Backbone.Model(name:"ACTION2", base:"fire")
            ,
              new Backbone.Model(name:"ACTION3", base:"move")
            ]
          )
          fleet = new Backbone.Collection([
              modelShip
          ])

          g =
            getCurrentControllingPlayer:()->
              new Backbone.Model(
                fleet:fleet
              )
          acovm.setGame(g)
          jm.when(acovm.setAssetSuper)(m.anything()).then(()->
            acovm.get("nominatedAssets").push(acovm.get("ships").at(1))
          )
        )

        test("Calls parent implementation.", ()->
          acovm.setAsset("MODEL 2")
          jm.verify(acovm.setAssetSuper)("MODEL 2")
        )
        test("parent implementation throws - throws", ()->
          jm.when(acovm.setAssetSuper)(m.anything()).then(()->throw new Error())
          a(()->
            acovm.setAsset("MODEL 2")
          , m.raisesAnything())
        )
        test("parent implementation fails to create itself a 'nominatedAssets' collection with at least one item in it - throws", ()->
          jm.when(acovm.setAssetSuper)(m.anything()).then(()->
            acovm.get("nominatedAssets").reset()
          )
          a(()->
            acovm.setAsset("MODEL 2")
          ,
            m.raisesAnything())
        )
        test("any part of property chain game.getCurrentControllingPlayer().get('fleet') missing - throws", ()->
          fleet.reset()
          a(()->
            acovm.setAsset("MODEL 2")
          , m.raisesAnything())
        )
        test("Retrieves command data from getAvailableAssets on model ship", ()->
          acovm.setAsset("MODEL 2")
          jm.verify(modelShip.getAvailableActions)()
        )
        suite("Array of models returned.", ()->
          test("adds a command with label and same as action name and viewModel ship as target for all commands", ()->
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
          test("sets overlay to different strings for different bases", ()->
            acovm.setAsset("MODEL 2")
            a(acovm.get("commands").at(1).get("overlay"), m.string())
            a(acovm.get("commands").at(2).get("overlay"), m.string())
            a(acovm.get("commands").at(2).get("overlay"), m.not(acovm.get("commands").at(1).get("overlay")))
          )
          test("sets null overlay where base is not set", ()->
            acovm.setAsset("MODEL 2")
            a(acovm.get("commands").at(0).get("overlay"), m.nil())
          )
          test("sets null overlay where base is not recognised", ()->
            jm.when(modelShip.getAvailableActions)().then(()->
              [
                new Backbone.Model(name:"ACTION1", base:"SOMETHING")
              ,
                new Backbone.Model(name:"ACTION2", base:"fire")
              ,
                new Backbone.Model(name:"ACTION3", base:"move")
              ]
            )
            acovm.setAsset("MODEL 2")
            a(acovm.get("commands").at(0).get("overlay"), m.nil())
          )
          test("sets select function on command items", ()->
            acovm.setAsset("MODEL 2")
            a(acovm.get("commands").at(0).get("select"), m.func())
            a(acovm.get("commands").at(1).get("select"), m.func())
            a(acovm.get("commands").at(2).get("select"), m.func())
          )
          suite("command select function", ()->
            setup(()->
              acovm.setAsset("MODEL 2")
            )
            test("sets viewModel 'selectedCommand' to object", ()->
              acovm.get("commands").at(1).get("select")()
              a(acovm.get("selectedCommand"),acovm.get("commands").at(1))
            )
          )
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
)

