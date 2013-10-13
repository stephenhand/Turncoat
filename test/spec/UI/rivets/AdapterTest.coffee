define(["isolate!UI/rivets/adapter"], (Adapter)->
  suite("Adapter", ()->
      suite("constructor", ()->
        test("setsUpAdapter", ()->
          chai.assert.isFunction(Adapter.subscribe)
          chai.assert.isFunction(Adapter.unsubscribe)
          chai.assert.isFunction(Adapter.read)
          chai.assert.isFunction(Adapter.publish)
        )
      )
      suite("subscribe", ()->
        test("SimpleBackboneModelAttribute_BindsToModelChangeEventForAttribute", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          callback = JsMockito.mockFunction()
          mod.on=JsMockito.mockFunction()
          Adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
          JsMockito.verify(mod.on)("change:MOCK_ATTRIBUTE")
        )
        test("SimpleBackboneModelAttributeThatSupportsEvents_BindsToModelAttributesAddRemoveResetEvents", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:new Backbone.Collection()
          )
          mod.get("MOCK_ATTRIBUTE").on=JsMockito.mockFunction()
          callback = JsMockito.mockFunction()
          Adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
          JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("add", callback)
          JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("remove", callback)
          JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("reset", callback)
        )

      )
      suite("unsubscribe", ()->
        test("SimpleBackboneModelAttribute_UnbindsFromModelChangeEventForAttribute", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          mod.off=JsMockito.mockFunction()
          callback = JsMockito.mockFunction()
          Adapter.unsubscribe(mod,"MOCK_ATTRIBUTE",callback)
          JsMockito.verify(mod.off)("change:MOCK_ATTRIBUTE")
        )

      )
      suite("read", ()->
        test("SimpleBackboneModelAttribute_Reads", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          chai.assert.equal(Adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_VALUE")
        )
        test("BackboneCollection_ReadsAsModels", ()->
          mod= new Backbone.Collection([
            a:3
          ,
            a:5
          ,
            a:9
          ])
          chai.assert.equal(Adapter.read(mod)[0].get("a"),3)
          chai.assert.equal(Adapter.read(mod)[1].get("a"),5)
          chai.assert.equal(Adapter.read(mod)[2].get("a"),9)
        )
        test("ChainedBackboneModel_ReadsAttribute", ()->
          mod= new Backbone.Model(
            MOCK_SUBMODEL:new Backbone.Model(
              MOCK_FURTHER_SUBMODEL:new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_NESTED_VALUE"
              )
            )
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          chai.assert.equal(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"),"MOCK_NESTED_VALUE")
        )
        test("MissingChainLink_ReturnsUndefined", ()->
          mod= new Backbone.Model(

          )
          chai.assert.isUndefined(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"))
        )
        test("ChainedBackboneCollection_ReadsAsModels", ()->
          mod= new Backbone.Model(
            MOCK_SUBMODEL:new Backbone.Model(
              MOCK_FURTHER_SUBMODEL:new Backbone.Model(
                MOCK_COLLECTION:new Backbone.Collection([
                  a:2
                ,
                  a:4
                ,
                  a:8
                ])
              )
            )
            MOCK_ATTRIBUTE:"MOCK_VALUE"
            MOCK_COLLECTION:new Backbone.Collection([
              a:3
            ,
              a:5
            ,
              a:9
            ])

          )
          chai.assert.equal(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[0].get("a"),2)
          chai.assert.equal(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[1].get("a"),4)
          chai.assert.equal(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[2].get("a"),8)
        )
      )

  )


)

