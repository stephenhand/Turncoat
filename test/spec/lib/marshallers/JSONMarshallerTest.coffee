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
    mockMarshalledType ="{ "+
      "\"_type\":\"MOCK_TYPE\","+
      "\"propA\":\"valA\" ,"+
      "\"propB\":\"valB\","+
      "\"unknownObject\":{"+
        "\"propC\":4,"+
        "\"propD\":\"valD\""+
      " },"+
      "\"knownObject\":{"+
        "\"_type\":\"MOCK_TYPE\","+
        "\"propE\":4,"+
        "\"propF\":\"valF\","+
        "\"collection\":["+
          "{\"propG\":\"valG\"},"+
          "{\"propH\":\"valH\"},"+
          "{\"_type\":\"MOCK_TYPE\",\"propI\":\"valH\"}"+
        "]"+
      " }"+
    " }"
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

      test("createsArraysFromCollections", ()->
        testModelType = Backbone.Model.extend(
          toString:mockFunction()
          initialize:()->
        )
        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )
        modelA =  new mockType()
        modelA.set(
          propA:"TEST_STRING"
          propB:11
        )
        modelB =  new mockType()
        modelB.set(
          propA:"TEST_STRING"
          propB:22
        )
        modelC =  new mockType()
        modelC.set(
          propA:"TEST_STRING"
          propB:33
        )
        col = new Backbone.Collection([
          modelA
        ,
          modelB
        ,
          modelC
        ])
        testModel.set("propC", col)
        #mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[testModelType]="MOCK_TYPE"

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel.propC.length, 3)
        chai.assert.equal(parsedModel.propC[1].propB, 22)
      )

      test("sets_typeForKnownTypesInArrays", ()->
        testModelType = Backbone.Model.extend(
          toString:mockFunction()
          initialize:()->
        )
        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )
        modelA =  new mockType()
        modelA.set(
          propA:"TEST_STRING"
          propB:11
        )
        modelB =  new mockType()
        modelB.set(
          propA:"TEST_STRING"
          propB:22
        )
        modelC =  new mockType()
        modelC.set(
          propA:"TEST_STRING"
          propB:33
        )
        col = new Backbone.Collection([
          modelA
        ,
          modelB
        ,
          modelC
        ])
        testModel.set("propC", col)
        #mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[testModelType]="MOCK_TYPE"

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        chai.assert.equal(parsedModel.propC[1]._type, "MOCK_TYPE")
      )
    )

    suite("unmarshalState", ()->
      test("createsBackboneModel", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.set)
        chai.assert.isFunction(ut.unset)
        chai.assert.isFunction(ut.get)
        chai.assert.isObject(ut.attributes)
      )
      test("createsBackboneModelForUnknownSubType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.get("unknownObject").set)
        chai.assert.isFunction(ut.get("unknownObject").unset)
        chai.assert.isFunction(ut.get("unknownObject").get)
        chai.assert.isObject(ut.get("unknownObject").attributes)
      )
      test("createsBackboneModelForKnownSubType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.get("knownObject").set)
        chai.assert.isFunction(ut.get("knownObject").unset)
        chai.assert.isFunction(ut.get("knownObject").get)
        chai.assert.isObject(ut.get("knownObject").attributes)
      )
      test("preservesMarshalledData", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.equal(ut.get("propA"),"valA")
        chai.assert.equal(ut.get("propB"),"valB")
      )
      test("preservesMarshalledDataInUnknownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.equal(ut.get("unknownObject").get("propC"),4)
        chai.assert.equal(ut.get("unknownObject").get("propD"),"valD")
      )
      test("preservesMarshalledDataInKnownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.equal(ut.get("knownObject").get("propE"),4)
        chai.assert.equal(ut.get("knownObject").get("propF"),"valF")
      )
      test("correctlyUnmarshalsKnownTypeToCorrectType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.mockMethod)
        chai.assert.equal(ut.mockMethod(),"CHEESE")
      )
      test("createsBackboneCollectionFromArray", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.get("knownObject").get("collection").unshift)
        chai.assert.isFunction(ut.get("knownObject").get("collection").shift)
      )
      test("vivifiesUnknownCollectionMembersAsBackboneModels", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.get("knownObject").get("collection").at(0).set)
        chai.assert.isFunction(ut.get("knownObject").get("collection").at(0).unset)
        chai.assert.isFunction(ut.get("knownObject").get("collection").at(0).get)
        chai.assert.isObject(ut.get("knownObject").get("collection").at(0).attributes)
      )
      test("vivifiesKnownCollectionMembersAsCorrectType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.get("knownObject").get("collection").at(2).mockMethod)
        chai.assert.equal(ut.get("knownObject").get("collection").at(2).mockMethod(),"CHEESE")
      )

    )

  )


)