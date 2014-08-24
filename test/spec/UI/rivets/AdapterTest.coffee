
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
        test("Attribute exists as direct property - uses property", ()->
          mod= new Backbone.Model(
          )
          mod.MOCK_ATTRIBUTE="MOCK_PROPERTY_VALUE"
          a(Adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_PROPERTY_VALUE")
        )
        test("Attribute exists as direct property and backbone attribute - uses property in preference", ()->
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          mod.MOCK_ATTRIBUTE="MOCK_PROPERTY_VALUE"
          a(Adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_PROPERTY_VALUE")
        )
        test("Attribute specified points to Backbone Collection - returns collection's models array", ()->
          mod= new Backbone.Model(a:new Backbone.Collection([
              a:3
            ,
              a:5
            ,
              a:9
            ])
          )
          a(Adapter.read(mod, "a"), mod.get("a").models)
        )
        test("Property specified points to Backbone Collection - returns collection's models array", ()->
          mod= new Backbone.Model()
          mod.a=new Backbone.Collection([
            a:3
          ,
            a:5
          ,
            a:9
          ])
          a(Adapter.read(mod, "a"), mod.a.models)
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

