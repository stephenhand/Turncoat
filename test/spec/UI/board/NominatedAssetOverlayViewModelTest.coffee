require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/board/NominatedAssetOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          @setGameMock = JsMockito.mockFunction()
          @initializeMock = JsMockito.mockFunction()
          @setAssetMock = JsMockito.mockFunction()
          super()
        setGame:(game)->
          @setGameMock(game)
        initialize:()->
          @initializeMock()
        setAsset:(id)->
          @setAssetMock(id)
      ret
    )
  )
)

define(["isolate!UI/board/NominatedAssetOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone"], (NominatedAssetOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/NominatedAssetOverlayViewModel"]
  suite("NominatedAssetOverlayViewModel", ()->
    naovm = null
    setup(()->
      naovm = new NominatedAssetOverlayViewModel()
      naovm.set("ships",
        new Backbone.Collection([
          modelId:"MODEL 1"
        ,
          modelId:"MODEL 2"
        ,
          modelId:"MODEL 3"
        ])
      )
    )
    suite("setAsset", ()->

      suite("has valid ships collection", ()->
        suite("called with id matching modeld of ship in collection", ()->

          test("adds ship to nominated assets collection", ()->
            naovm.setAsset("MODEL 2")
            a(naovm.get("nominatedAssets").models, m.equivalentArray([naovm.get("ships").at(1)]))
          )
          test("removes anything already nominated assets collection", ()->
            naovm.set("nominatedAssets", new Backbone.Collection([
              "OTHER"
            ,
              "STUFF"
            ]))
            naovm.setAsset("MODEL 2")
            a(naovm.get("nominatedAssets").models, m.equivalentArray([naovm.get("ships").at(1)]))
          )

          test("called with id not matching modelId in ships collection - throws", ()->
            a(()->
              naovm.setAsset("CHEESE")
            ,
              m.raisesAnything()
            )
          )
        )
        test("called with nothing - empties nominatedAssets", ()->
          naovm.set("nominatedAssets", new Backbone.Collection([
            "OTHER"
          ,
            "STUFF"
          ]))
          naovm.setAsset()
          a(naovm.get("nominatedAssets"),m.hasMember("models", m.empty()))
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
    suite("getAsset", ()->
      test("Asset set - returns first asset in nominated assets collection", ()->
        naovm.setAsset("MODEL 2")
        a(naovm.getAsset(), naovm.get("ships").at(1))
      )

      test("Asset not set - returns nothing", ()->
        a(naovm.getAsset(), m.nil())
      )
    )
  )
)

