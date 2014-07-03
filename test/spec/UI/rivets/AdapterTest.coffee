
define(["isolate!UI/rivets/adapter", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (Adapter, m, o, a, jm, v)->
  suite("Adapter", ()->
      suite("constructor", ()->
        test("Sets up adapter", ()->
          a(Adapter.subscribe, m.func())
          a(Adapter.unsubscribe, m.func())
          a(Adapter.read, m.func())
          a(Adapter.publish, m.func())
        )
      )
      suite("subscribe", ()->
        test("Simple Backbone Model Attribute - binds to model change event for attribute", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          callback = JsMockito.mockFunction()
          mod.on=JsMockito.mockFunction()
          Adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
          jm.verify(mod.on)("change:MOCK_ATTRIBUTE")
        )
        test("Simple Backbone Model attribute that supports events - binds to model attributes Add, Remove, Reset events", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:new Backbone.Collection()
          )
          mod.get("MOCK_ATTRIBUTE").on=JsMockito.mockFunction()
          callback = jm.mockFunction()
          Adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
          jm.verify(mod.get("MOCK_ATTRIBUTE").on)("add", callback)
          jm.verify(mod.get("MOCK_ATTRIBUTE").on)("remove", callback)
          jm.verify(mod.get("MOCK_ATTRIBUTE").on)("reset", callback)
        )

      )
      suite("unsubscribe", ()->
        test("Simple Backbone Model attribute - Unbinds from model change event for attribute", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          mod.off=jm.mockFunction()
          callback = jm.mockFunction()
          Adapter.unsubscribe(mod,"MOCK_ATTRIBUTE",callback)
          jm.verify(mod.off)("change:MOCK_ATTRIBUTE")
        )

      )
      suite("read", ()->
        test("Simple Backbone Model Attribute - Reads", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          a(Adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_VALUE")
        )
        test("Backbone Collection - Reads as models", ()->
          mod= new Backbone.Collection([
            a:3
          ,
            a:5
          ,
            a:9
          ])
          a(Adapter.read(mod)[0].get("a"),3)
          a(Adapter.read(mod)[1].get("a"),5)
          a(Adapter.read(mod)[2].get("a"),9)
        )
        test("Chained Backbone Model - reads attribute", ()->
          mod= new Backbone.Model(
            MOCK_SUBMODEL:new Backbone.Model(
              MOCK_FURTHER_SUBMODEL:new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_NESTED_VALUE"
              )
            )
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          a(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"),"MOCK_NESTED_VALUE")
        )
        test("Missing Chain Link - returns undefined", ()->
          mod= new Backbone.Model(

          )
          a(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"), m.nil())
        )
        test("Chained Backbone Collection - Reads As Models", ()->
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
          a(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[0].get("a"),2)
          a(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[1].get("a"),4)
          a(Adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[2].get("a"),8)
        )
        suite("_indexOf reserved key", ()->
          test("Model has collection property - returns index of model in collection", ()->
              mod= new Backbone.Model()
              coll=new Backbone.Collection([
                "SOMETHING"
              ,
                "SOMETHING"
              ,
                "SOMETHING"
              ,
                "SOMETHING"
              ,
                mod
              ,
                "SOMETHING"
              ,
                "SOMETHING"
              ])

              a(Adapter.read(mod,"_indexOf"),4)

          )
          test("Model has _indexOf property - ignores and returns index", ()->
            mod= new Backbone.Model(_indexOf:"A VALUE")
            coll = new Backbone.Collection([
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              mod
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ])
            a(Adapter.read(mod,"_indexOf"),4)

          )
          test("Model has no collection property - returns -1", ()->
            mod= new Backbone.Model()
            a(Adapter.read(mod,"_indexOf"),-1)
          )
          test("Model has no collection property and _indexOf property - returns -1", ()->
            mod= new Backbone.Model(_indexOf:"A VALUE")
            a(Adapter.read(mod,"_indexOf"),-1)
          )
          test("Model has collection property with no indexOf function - throws", ()->
            mod= new Backbone.Model()
            mod.collection={}
            a(()->
              Adapter.read(mod,"_indexOf")
            ,m.raisesAnything())
          )
        )
        suite("_length reserved key", ()->
          test("Model - 0", ()->
            mod= new Backbone.Model(
              "a":"a VALUE"
              "b":"a VALUE"
              "c":"a VALUE"
            )
            a(Adapter.read(mod,"_length"),0)

          )
          test("Model with _length attribute - still returns 0", ()->
            mod= new Backbone.Model(
              "_length":"a VALUE"
              "b":"a VALUE"
              "c":"a VALUE"
            )
            a(Adapter.read(mod,"_length"),0)

          )
          test("Collection - returns length of collection", ()->
            coll = new Backbone.Collection([
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ])
            a(Adapter.read(coll,"_length"),7)

          )
          test("Model in a collection - returns length of collection", ()->
            mod = new Backbone.Model()
            coll = new Backbone.Collection([
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              "SOMETHING"
            ,
              mod
            ,
              "SOMETHING"
            ])
            a(Adapter.read(mod,"_length"),5)

          )
        )
      )

  )


)

