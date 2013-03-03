define(["isolate!lib/marshallers/JSONMarshaller", "underscore", "backbone"], (JSONMarshaller, _, Backbone)->
  #JSONMarshallerTest.coffee test file    
  suite("JSONMarshaller", ()->
    marshaller = {}
    setup(()->
      marshaller = new JSONMarshaller()
    )
    suite("marshalState", ()->
      test("correctlyMarshalsBackboneModelsAttributes", ()->
        testModelType = Backbone.Model.extend(
          toString:mockFunction()
          initialize:()->
        )
        testModel = new testModelType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )
        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel.propA, "TEST_STRING")
        chai.assert.equal(parsedModel.propB, 42)
      )

    )
  )


)