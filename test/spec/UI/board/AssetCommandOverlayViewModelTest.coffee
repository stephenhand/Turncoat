require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!UI/board/AssetCommandOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone"], (AssetCommandOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/AssetCommandOverlayViewModel"]
  suite("AssetCommandOverlayViewModel", ()->
    suite("initialize", ()->
      test("sets nominatedAssets as empty collection", ()->
        a(new AssetCommandOverlayViewModel().get("nominatedAssets"), m.allOf(m.instanceOf(Backbone.Collection), m.hasMember("models", m.empty())))
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

