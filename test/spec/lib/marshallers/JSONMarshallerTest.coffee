require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/TypeRegistry", "lib/marshallers/JSONMarshaller", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      m=
        reverseLookup:JsMockito.mockFunction()
        registerPersister:JsMockito.mockFunction()
      m
    )
  )
)


define(["isolate!lib/marshallers/JSONMarshaller", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers",  "underscore", "backbone"], (JSONMarshaller, m, o, a, jm, v, _, Backbone)->
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
      toString:()->
        "MOCK_TYPE"
    )
    mockType.toString = ()->
      "ME AS A STRING!"
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
      mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"]["MOCK_TYPE"]=jm.mockFunction()
      jm.when(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"]["MOCK_TYPE"])(m.anything()).then((data)->
        val = new mockType()
        val.data = data
        val
      )
      jm.when(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"].reverseLookup)(m.anything()).then(()->"MOCK_TYPE")

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
        a(parsedModel.propA, "TEST_STRING")
        a(parsedModel.propB, 42)
      )
      test("correctlyPreservesTypeIn_typeAttribute", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
        )

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        a(parsedModel._type, "MOCK_TYPE")
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
        a(parsedModel.propC._type, "MOCK_TYPE")
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
        a(parsedModel.propC.propF.propI._type, "MOCK_TYPE")
      )

      test("correctlyPreservesType_typeAttributeInCollection", ()->

        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
          propC:new mockType()
        )


        json = marshaller.marshalState(new Backbone.Collection([testModel]))
        parsedModel = JSON.parse(json)
        a(parsedModel[0].propC._type, "MOCK_TYPE")
      )

      test("correctlyPreservesType_typeAttributeInDeepCollection", ()->


        testModel = new mockType()
        testModel.set(
          propA:"TEST_STRING"
          propB:42
          propC:new mockType()
        )

        testModel.get("propC").set(
            propD:"TEST_STRING"
            propE:""
            propF:new Backbone.Collection([new mockType()])
        )


        testModel.get("propC").get("propF").at(0).set(
          propG:"TEST_STRING"
          propH:""
          propI:new mockType()
        )
        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        a(parsedModel.propC.propF[0].propI._type, "MOCK_TYPE")
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
        a(parsedModel.propB._type, m.nil())
        a(parsedModel.propB.innerProp, "ANYTHING")
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
        origAttr = {}
        origAttrCount = 0
        for attrName, attrVal of testModel.attributes
          origAttr[attrName] = attrVal
          origAttrCount++
        marshaller.marshalState(testModel)
        newAttrCount = 0
        for attrName, attrVal of testModel.attributes
          a(attrVal, origAttr[attrName])
          newAttrCount++
        a(origAttrCount, newAttrCount)
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
          a(attrVal, origAttr[attrName])
          newAttrCount++
        a(origAttrCount, newAttrCount)
      )


      test("leavesAttributesUnmodifiedInCollections", ()->

        testModel = new mockType()
        testModel.set(
          id:"CHEESE"
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
        for attrName, attrVal of testModel.attributes
          origAttr[attrName] = attrVal
          origAttrCount++
        marshaller.marshalState(new Backbone.Collection([
          testModel
        ,
          new mockType()
        ,
          new mockType()
        ]
        ))
        newAttrCount = 0
        for attrName, attrVal of testModel.attributes
          a(attrVal, origAttr[attrName])
          newAttrCount++
        a(origAttrCount, newAttrCount)
      )

      test("createsArraysFromCollections", ()->
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
        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        a(parsedModel.propC.length, 3)
        a(parsedModel.propC[1].propB, 22)
      )

      test("setsTypeForKnownTypesInArrays", ()->
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

        json = marshaller.marshalState(testModel)
        parsedModel = JSON.parse(json)
        a(parsedModel.propC[1]._type, "MOCK_TYPE")
      )
      test("Throws if called with nothing", ()->
        a(()->
          marshaller.marshalState()
        ,
          m.raisesAnything()
        )
      )
    )

    suite("unmarshalState", ()->
      test("createsBackboneModel", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.set, m.func())
        a(ut.unset, m.func())
        a(ut.get, m.func())
        a(ut.attributes, m.object())
      )
      test("createsBackboneModelForUnknownSubType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.unknownObject.set, m.func())
        a(ut.data.unknownObject.unset, m.func())
        a(ut.data.unknownObject.get, m.func())
        a(ut.data.unknownObject.attributes, m.object())
      )
      test("callsRegisteredVivifierForKnownSubSype", ()->
        marshaller.unmarshalState(mockMarshalledType)
        JsMockito.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data._type is "MOCK_TYPE" &&
            data.propA is "valA" &&
            data.propB is "valB"
        ))
      )

      test("preservesMarshalledDataInUnknownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.unknownObject.get("propC"),4)
        a(ut.data.unknownObject.get("propD"),"valD")
      )
      test("vivifiesKnownObject1Deep", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        jm.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data._type is "MOCK_TYPE" &&
            data.propE is 4 &&
            data.propF is "valF"
        ))

        a(ut.data.knownObject,m.instanceOf(mockType))
      )
      test("createsBackboneCollectionFromArray", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.knownObject.data.collection.unshift, m.func())
        a(ut.data.knownObject.data.collection.shift, m.func())
      )
      test("vivifiesUnknownCollectionMembersAsBackboneModels", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.knownObject.data.collection.at(0).set, m.func())
        a(ut.data.knownObject.data.collection.at(0).unset, m.func())
        a(ut.data.knownObject.data.collection.at(0).get, m.func())
        a(ut.data.knownObject.data.collection.at(0).attributes, m.object())
      )
      test("vivifiesKnownCollectionMembersAsCorrectType", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        jm.verify(mockLibrary["lib/marshallers/JSONMarshaller"]["lib/turncoat/TypeRegistry"]["MOCK_TYPE"])(new JsHamcrest.SimpleMatcher(
          matches:(data)->
            data.propI is "valH"
        ))
        a(ut.data.knownObject.data.collection.at(2), m.instanceOf(mockType))
        a(ut.data.knownObject.data.collection.at(2).mockMethod, m.func())
      )
      test("Vivifies known object with getRoot function which returns root", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.knownObject.getRoot(),ut)
      )
      test("Vivifies unknown object with linkback function to root", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.unknownObject.getRoot(),ut)
      )
      test("Vivifies array with linkback to root", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut.data.knownObject.data.collection.getRoot(),ut)
      )
      test("Does not create root with a linkback to itself", ()->
        ut = marshaller.unmarshalState(mockMarshalledType)
        a(ut._root ,m.nil())
      )
      test("Throws if called with nothing", ()->
        a(()->
          marshaller.unmarshalState()
        ,
          m.raisesAnything()
        )
      )

    )

    suite("Model", ()->
      origParse=JSON.parse
      origStringify=JSON.stringify
      setup(()->
        JSON.parse=jm.mockFunction()
        jm.when(JSON.parse)(m.anything()).then((input)->
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
        JSON.stringify=jm.mockFunction()

      )
      teardown(()->
        JSON.parse=origParse
        JSON.stringify=origStringify
      )
      suite("unmarshalModel", ()->
        test("wrapsJSONParse", ()->
          marshaller.unmarshalModel("MOCK_JSON")
          jm.verify(JSON.parse)("MOCK_JSON")
        )
        test("IsNotArray_returnsBackboneModel", ()->
          val = marshaller.unmarshalModel("MOCK_JSON")
          a(val, m.instanceOf(Backbone.Model))
          a("FAKE_PARSED_PROPERTY_VALUE", val.get("FAKE_PARSED_PROPERTY"))
        )
        test("IsArray_returnsBackboneCollection", ()->
          val = marshaller.unmarshalModel("MOCK_JSON_ARRAY")
          m.instanceOf(val, m.instanceOf(Backbone.Collection))
          a("FAKE_PARSED_PROPERTY_VALUE2", val.at(1).get("FAKE_PARSED_PROPERTY"))
        )
        test("hasTypeProperty_ignoresTypePropertyAndUnmarhalsAsModel",()->
          ret=marshaller.unmarshalModel(mockMarshalledType)
          a(ret, m.not(m.instanceOf(mockType)))
          a("MOCK_TYPE", ret.get("_type"))
        )
      )
      suite("marshalModel", ()->
        test("backboneModel_callsJSONStringifyOnObject", ()->
          val = marshaller.marshalModel(new Backbone.Model(
              prop:"MOCK_VALUE"
            )
          )
          jm.verify(JSON.stringify)(m.hasMember("attributes",m.hasMember("prop","MOCK_VALUE")))
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
          jm.verify(JSON.stringify)(m.hasMember("models",m.hasItems(
            m.hasMember("attributes",m.hasMember("prop","MOCK_VALUE1")),
            m.hasMember("attributes",m.hasMember("prop","MOCK_VALUE2")),
            m.hasMember("attributes",m.hasMember("prop","MOCK_VALUE3"))
          )))
        )
        test("otherValue_throws", ()->
          a(
            ()->marshaller.marshalModel({})
          ,
            m.raisesAnything())
          a(
            ()->marshaller.marshalModel([])
          ,
            m.raisesAnything())
          a(
            ()->marshaller.marshalModel(22)
          ,m.raisesAnything())
          a(
            ()->marshaller.marshalModel("A STRING")
          ,m.raisesAnything())
          a(
            ()->marshaller.marshalModel(null)
          ,m.raisesAnything())
        )
        test("undefined_throws", ()->
          a(
            ()->marshaller.marshalModel()
          ,m.raisesAnything())
        )

      )
      suite("unmarshalAction",()->
        test("Proxies to unmarshalState", ()->
          marshaller.unmarshalState = jm.mockFunction()
          marshaller.unmarshalAction("A PARAMETER")
          jm.verify(marshaller.unmarshalState)("A PARAMETER")
        )
      )
      suite("marshalAction",()->
        test("Proxies to marshalState", ()->
          marshaller.marshalState = jm.mockFunction()
          marshaller.marshalAction("A PARAMETER")
          jm.verify(marshaller.marshalState)("A PARAMETER")
        )
      )
    )

  )


)