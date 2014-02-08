define(["isolate!lib/backboneTools/ModelProcessor", "jsMockito", "jsHamcrest", "chai"], (ModelProcessor, jm, h, c)->
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ModelProcessor", ()->
    suite("deepUpdate", ()->
      test("Target is not Backbone model or Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate({}, new Backbone.Model())
        )
      )
      test("Updated model is not Backbone model or Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Model(), {})
        )
      )
      test("Target is Model but updated is Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Model(), new Backbone.Collection())
        )
      )
      test("Target is Collection but updated is Model - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Collection(), new Backbone.Model())
        )
      )
      suite("Single modcl", ()->
        test("Returns target model", ()->
          chai.assert.fail()
        )
      )
    )
  )


)

