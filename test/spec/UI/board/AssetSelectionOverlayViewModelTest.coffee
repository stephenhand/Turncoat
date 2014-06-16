require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!UI/board/AssetSelectionOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers"], (AssetSelectionOverlayViewModel, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/AssetSelectionOverlayViewModel"]
  suite("AssetSelectionOverlayViewModel", ()->
    suite("setNominatedAsset", ()->
      asovm = null
      setup(()->
        asovm=new AssetSelectionOverlayViewModel()
      )
      suite("No asset currently nominated",()->
        test("Asset provided - sets models' 'nominated asset' to that supplied", ()->
          asset = new Backbone.Model(id:"ship2")
          asovm.setNominatedAsset(asset)
          a(asovm.get("nominatedAsset"), asset)
        )
        test("Asset provided - sets 'nominated' to true on asset nominated", ()->
          asset = new Backbone.Model(id:"ship2")
          asovm.setNominatedAsset(asset)
          a(asset.get("nominated"))
        )
        test("Asset not provided - sets models' 'nominated asset' to nil", ()->
          asovm.setNominatedAsset()
          a(asovm.get("nominatedAsset"), m.nil())
        )
        suite("No asset currently nominated",()->
          current = null
          setup(()->
            current = new Backbone.Model(id:"ship4")
            asovm.setNominatedAsset(current)
          )
          test("Asset provided - sets models' 'nominated asset' to that supplied", ()->
            asset = new Backbone.Model(id:"ship8")
            asovm.setNominatedAsset(asset)
            a(asovm.get("nominatedAsset"), asset)
          )
          test("Asset provided - sets 'nominated' to true on asset nominated", ()->
            asset = new Backbone.Model(id:"ship8")
            asovm.setNominatedAsset(asset)
            a(asset.get("nominated"))
          )
          test("Asset provided - unsets 'nominated' on previous nominated asset", ()->
            asset = new Backbone.Model(id:"ship8")
            asovm.setNominatedAsset(asset)
            a(current.get("nominated"), m.nil())
          )
          test("Asset not provided - unsets 'nominated' on previous nominated asset", ()->
            asovm.setNominatedAsset()
            a(current.get("nominated"), m.nil())
          )
          test("Asset not provided - unsets 'nominatedAsset'", ()->
            asovm.setNominatedAsset()
            a(current.get("nominated"), m.nil())
          )
        )
      )
    )
  )
)

