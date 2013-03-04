define(["isolate!lib/marshallers/JSONMarshaller", "underscore", "backbone"], (JSONMarshaller, _, Backbone)->
  #JSONMarshallerTest.coffee test file    
  suite("JSONMarshaller", ()->
    marshaller = {}
    mockType = Backbone.Model.extend(
      attributes:
        A:"A"
        B:"B"
        C:"C"
      mockMethod:()->
        "CHEESE"
    )
    mockMarshalledType ="{"+
      "_type:\"MOCK_TYPE\","+
      "propA:\"valA\" ,"+
      "propB:\"valB\","+
      "unknownObject:{"+
        "propC:4"+
        "propD:\"valD\""+
      "}"+
      "knownObject:{"+
        "_type:\"MOCK_TYPE\""+
        "propE:4"+
        "propF:\"valF\""+
      "}"
    "}"
    setup(()->
      marshaller = new JSONMarshaller()
      mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"]=mockType
      mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[mockType]="MOCK_TYPE"
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

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel._type, "MOCK_TYPE")
      )
      test("correctlyPreservesTypeIn_typeAttribute1LevelDeep", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
          propC:new mockType()
        )


        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel.propC._type, "MOCK_TYPE")
      )

      test("correctlyPreservesTypeIn_typeAttribute3LevelsDeep", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
          propC:new mockType()
        )

        testModel.get("propC").set(
          propD:"TEST_STRING"
          propE:""
          propF:new mockType()
        )


        testModel.get("propC").get("propF").set(
          propG:"TEST_STRING"
          propH:""
          propI:new mockType()
        )
        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel.propC.propF.propI._type, "MOCK_TYPE")
      )

      test("recursiveTypeRecordingIgnoresNonModelObjects", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:{innerProp:"ANYTHING"}
          propC:new mockType()
        )


        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.isUndefined(parsedModel.propB._type)
        chai.assert.equal(parsedModel.propB.innerProp, "ANYTHING")
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
        #mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[testModelType]="MOCK_TYPE"
        origAttr = {}
        origAttrCount = 0
        for attrName, attrVal of testModel.attributes
          origAttr[attrName] = attrVal
          origAttrCount++
        json = marshaller.marshalState(testModel)
        newAttrCount = 0
        for attrName, attrVal of testModel.attributes
          chai.assert.equal(attrVal, origAttr[attrName])
          newAttrCount++
        chai.assert.equal(origAttrCount, newAttrCount)
      )

      test("leavesAttributesUnmodified3LevelsDeep", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
          propC:new mockType()
        )

        testModel.get("propC").set(
          propD:"TEST_STRING"
          propE:""
          propF:new mockType()
        )


        testModel.get("propC").get("propF").set(
          propG:"TEST_STRING"
          propH:""
          propI:new mockType()
        )
        origAttr = {}
        origAttrCount = 0
        for attrName, attrVal of testModel.get("propC").get("propF").attributes
          origAttr[attrName] = attrVal
          origAttrCount++
        json = marshaller.marshalState(testModel)
        newAttrCount = 0
        for attrName, attrVal of testModel.get("propC").get("propF").attributes
          chai.assert.equal(attrVal, origAttr[attrName])
          newAttrCount++
        chai.assert.equal(origAttrCount, newAttrCount)
      )

    )



    suite("unmarshalState", ()->
      test("CorrectlyUnmarshalsKnownTypeToCorrectType", ()->

      )

    )

  )


)