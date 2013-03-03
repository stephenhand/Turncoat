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
      test("correctlyPreservesTypeIn_typeAttribute", ()->
        testModelType = Backbone.Model.extend(
          toString:mockFunction()
          initialize:()->
        )
        testModel = new testModelType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )
        mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[testModelType]="MOCK_TYPE"

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel._type, "MOCK_TYPE")
      )
      test("leavesAttributesUnmodified", ()->
        testModelType = Backbone.Model.extend(
          toString:mockFunction()
          initialize:()->
        )
        testModel = new testModelType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )
        mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[testModelType]="MOCK_TYPE"
        origAttr = {}
        origAttrCount = 0
        for attrToCopy, attrName of testModel.attributes
          origAttr[attrName] = attrToCopy
          origAttrCount++
        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        newAttrCount = 0
        for attrToCheck, attrName of origAttr
          chai.assert.equal(attrToCheck, testModel.attributes[attrName])
          newAttrCount++
        chai.assert.equal(origAttrCount, newAttrCount)
      )
    )


  )


)