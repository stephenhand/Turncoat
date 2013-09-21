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
    MOCK_TYPE = Backbone.Model.extend()
    mockMarshalledType ="{ "+
      "\"_type\":\"MOCK_TYPE\","+
      "\"_typeMap\":{"+
        "\"mappedProp\":\"MAPPED_TYPE\""+
      "},"+
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
      mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"]=JsMockito.mockFunction()
      JsMockito.when(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"])(JsHamcrest.Matchers.anything()).then((data)->
        val = new mockType()
        val.data = data
        val
      )
      mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"].reverse[mockType]="MOCK_TYPE"
    )
    suite("marshalState", ()->
      test("correctlyMarshalsBackboneModelsAttributes", ()->
        testModelType = Backbone.Model.extend(
          toString:JsMockito.mockFunction()
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
          toString:JsMockito.mockFunction()
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
        marshaller.marshalState(testModel)
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
          toString:JsMockito.mockFunction()
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

      test("setsTypeForKnownTypesInArrays", ()->
        testModelType = Backbone.Model.extend(
          toString:JsMockito.mockFunction()
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
        chai.assert.isFunction(ut.data.unknownObject.set)
        chai.assert.isFunction(ut.data.unknownObject.unset)
        chai.assert.isFunction(ut.data.unknownObject.get)
        chai.assert.isObject(ut.data.unknownObject.attributes)
      )
      test("callsRegisteredVivifierForKnownSubSype", ()->
        marshaller.unmarshalState(mockMarshalledType)
        JsMockito.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data._type is "MOCK_TYPE" &&
            data.propA is "valA" &&
            data.propB is "valB"
        ))
      )

      test("preservesMarshalledDataInUnknownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.equal(ut.data.unknownObject.get("propC"),4)
        chai.assert.equal(ut.data.unknownObject.get("propD"),"valD")
      )
      test("vivifiesKnownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        JsMockito.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data._type is "MOCK_TYPE" &&
            data.propE is 4 &&
            data.propF is "valF"
        ))

        chai.assert.instanceOf(ut.data.knownObject,mockType)
      )
      test("createsBackboneCollectionFromArray", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.data.knownObject.data.collection.unshift)
        chai.assert.isFunction(ut.data.knownObject.data.collection.shift)
      )
      test("vivifiesUnknownCollectionMembersAsBackboneModels", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        chai.assert.isFunction(ut.data.knownObject.data.collection.at(0).set)
        chai.assert.isFunction(ut.data.knownObject.data.collection.at(0).unset)
        chai.assert.isFunction(ut.data.knownObject.data.collection.at(0).get)
        chai.assert.isObject(ut.data.knownObject.data.collection.at(0).attributes)
      )
      test("vivifiesKnownCollectionMembersAsCorrectType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        JsMockito.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/StateRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data.propI is "valH"
        ))
        chai.assert.instanceOf(ut.data.knownObject.data.collection.at(2),mockType)
        chai.assert.isFunction(ut.data.knownObject.data.collection.at(2).mockMethod)
      )

    )
    suite("Model", ()->
      origParse=JSON.parse
      origStringify=JSON.stringify
      setup(()->
        JSON.parse=JsMockito.mockFunction()
        JsMockito.when(JSON.parse)(JsHamcrest.Matchers.anything()).then((input)->
          if input is "MOCK_JSON_ARRAY"
            return [
              FAKE_PARSED_PROPERTY:"FAKE_PARSED_PROPERTY_VALUE1"
            ,
              FAKE_PARSED_PROPERTY:"FAKE_PARSED_PROPERTY_VALUE2"
            ]
          else
            return {
              FAKE_PARSED_PROPERTY:"FAKE_PARSED_PROPERTY_VALUE"
              _type:"MOCK_TYPE"
            }
        )
        JSON.stringify=JsMockito.mockFunction()

      )
      teardown(()->
        JSON.parse=origParse
        JSON.stringify=origStringify
      )
      suite("unmarshalModel", ()->
        test("wrapsJSONParse", ()->
          marshaller.unmarshalModel("MOCK_JSON")
          JsMockito.verify(JSON.parse)("MOCK_JSON")
        )
        test("IsNotArray_returnsBackboneModel", ()->
          val = marshaller.unmarshalModel("MOCK_JSON")
          chai.assert.instanceOf(val, Backbone.Model)
          chai.assert.equal("FAKE_PARSED_PROPERTY_VALUE", val.get("FAKE_PARSED_PROPERTY"))
        )
        test("IsArray_returnsBackboneCollection", ()->
          val = marshaller.unmarshalModel("MOCK_JSON_ARRAY")
          chai.assert.instanceOf(val, Backbone.Collection)
          chai.assert.equal("FAKE_PARSED_PROPERTY_VALUE2", val.at(1).get("FAKE_PARSED_PROPERTY"))
        )
        test("hasTypeProperty_ignoresTypePropertyAndUnmarhalsAsModel",()->
          ret=marshaller.unmarshalModel(mockMarshalledType)
          chai.assert.notInstanceOf(ret, mockType)
          chai.assert.equal("MOCK_TYPE", ret.get("_type"))
        )
      )
      suite("marshalModel", ()->
        test("backboneModel_callsJSONStringifyOnObject", ()->
          val = marshaller.marshalModel(new Backbone.Model(
              prop:"MOCK_VALUE"
            )
          )
          JsMockito.verify(JSON.stringify)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("prop","MOCK_VALUE")))
        )
        test("backboneCollection_callsJSONStringifyOnObject", ()->
          val = marshaller.marshalModel(new Backbone.Collection(
            [
              prop:"MOCK_VALUE1"
            ,
              prop:"MOCK_VALUE2"
            ,
              prop:"MOCK_VALUE3"

            ])
          )
          JsMockito.verify(JSON.stringify)(JsHamcrest.Matchers.hasMember("models",JsHamcrest.Matchers.hasItems(
            JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("prop","MOCK_VALUE1")),
            JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("prop","MOCK_VALUE2")),
            JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("prop","MOCK_VALUE3"))
          )))
        )
        test("otherValue_throws", ()->
          chai.assert.throws(()->marshaller.marshalModel({}))
          chai.assert.throws(()->marshaller.marshalModel([]))
          chai.assert.throws(()->marshaller.marshalModel(22))
          chai.assert.throws(()->marshaller.marshalModel("A STRING"))
          chai.assert.throws(()->marshaller.marshalModel(null))
        )
        test("undefined_throws", ()->
          chai.assert.throws(()->marshaller.marshalModel())
        )

      )
    )

  )


)