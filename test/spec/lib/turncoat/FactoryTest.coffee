define(["isolate!lib/turncoat/Factory"], (Factory)->
  #FactoryTest.coffee test file    
  suite("Factory", ()->
    suite("registerStateMarshaller", ()->
      test("notRegisteringMakesDefaultBuildStateMarshallerThrow", ()->
        chai.assert.throws(()->
          Factory.buildStateMarshaller()
        )
      )
      test("notRegisteringMakesKeyedBuildStateMarshallerThrow", ()->
        chai.assert.throws(()->
          Factory.buildStateMarshaller("anything")
        )
      )
      test("registeringMakesStateMarshallerConstructibleByKey", ()->
        #implement test
        class testStateMarshaller
           constructor:()->
             @mockProperty="MOCK_VALUE"

        Factory.registerStateMarshaller("testStateMarshaller",testStateMarshaller)
        testObj = Factory.buildStateMarshaller("testStateMarshaller")
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
      test("registeringMakesBuildStateMarshallerWithIncorrectKeyReturnsNull", ()->
        #implement test
        class testStateMarshaller
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerStateMarshaller("testStateMarshaller",testStateMarshaller)
        chai.assert.isNull(
          Factory.buildStateMarshaller("anotherStateMarshaller",testStateMarshaller)
        )
      )
      test("registeringMakesStateMarshallerConstructibleIfSetAsDefault", ()->
        #implement test
        Factory.defaults =
          stateMarshaller:"testStateMarshaller"
        class testStateMarshaller
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerStateMarshaller("testStateMarshaller",testStateMarshaller)
        testObj = Factory.buildStateMarshaller()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
      test("registeringUsesConstuctorOptsWhenBuiltWithKey", ()->
        #implement test
        Factory.defaults =
          stateMarshaller:"paramaterisedStateMarshaller"
        class paramaterisedStateMarshaller
          constructor:(opts)->
            @mockProperty=opts.property

        Factory.registerStateMarshaller("paramaterisedStateMarshaller",paramaterisedStateMarshaller)
        testObj = Factory.buildStateMarshaller(
          "paramaterisedStateMarshaller",
          property:"MOCK_PARAM_PROPERTY_VALUE"
        )
        chai.assert.equal("MOCK_PARAM_PROPERTY_VALUE", testObj.mockProperty)
      )
      test("registeringUsesConstuctorOptsAsDefault", ()->
        #implement test
        Factory.defaults =
          stateMarshaller:"paramaterisedStateMarshaller"
        class paramaterisedStateMarshaller
          constructor:(opts)->
            @mockProperty=opts.property

        Factory.registerStateMarshaller("paramaterisedStateMarshaller",paramaterisedStateMarshaller)
        testObj = Factory.buildStateMarshaller(
          property:"MOCK_PARAM_PROPERTY_VALUE"
        )
        chai.assert.equal("MOCK_PARAM_PROPERTY_VALUE", testObj.mockProperty)
      )
    )
    suite("setDefaultMarshaller", ()->
      test("settingDefaultMarshallerUsesDefaultMarshallerInParameterlessBuildStateMarshaller", ()->
        #implement test
        class testStateMarshaller
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerStateMarshaller("testStateMarshaller",testStateMarshaller)
        Factory.setDefaultMarshaller("testStateMarshaller")
        testObj = Factory.buildStateMarshaller()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
    )

    suite("registerPersister", ()->
      test("notRegisteringMakesDefaultBuildPersisterThrow", ()->
        chai.assert.throws(()->
          Factory.buildPersister()
        )
      )
      test("notRegisteringMakesKeyedBuildPersisterThrow", ()->
        chai.assert.throws(()->
          Factory.buildPersister("anything")
        )
      )
      test("registeringMakesPersisterConstructibleByKey", ()->
        #implement test
        class testPersister
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerPersister("testPersister",testPersister)
        testObj = Factory.buildPersister("testPersister")
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
      test("registeringMakesBuildPersisterWithIncorrectKeyReturnsNull", ()->
        #implement test
        class testPersister
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerPersister("testPersister",testPersister)
        chai.assert.isNull(
          Factory.buildPersister("anotherPersister",testPersister)
        )
      )
      test("registeringMakesPersisterConstructibleIfSetAsDefault", ()->
        #implement test
        Factory.defaults =
          persister:"testPersister"
        class testPersister
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerPersister("testPersister",testPersister)
        testObj = Factory.buildPersister()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
      test("registeringUsesConstuctorOptsWhenBuiltWithKey", ()->
        #implement test
        Factory.defaults =
          persister:"paramaterisedPersister"
        class paramaterisedPersister
          constructor:(opts)->
            @mockProperty=opts.property

        Factory.registerPersister("paramaterisedPersister",paramaterisedPersister)
        testObj = Factory.buildPersister(
          "paramaterisedPersister",
          property:"MOCK_PARAM_PROPERTY_VALUE"
        )
        chai.assert.equal("MOCK_PARAM_PROPERTY_VALUE", testObj.mockProperty)
      )
      test("registeringUsesConstuctorOptsAsDefault", ()->
        #implement test
        Factory.defaults =
          persister:"paramaterisedPersister"
        class paramaterisedPersister
          constructor:(opts)->
            @mockProperty=opts.property

        Factory.registerPersister("paramaterisedPersister",paramaterisedPersister)
        testObj = Factory.buildPersister(
          property:"MOCK_PARAM_PROPERTY_VALUE"
        )
        chai.assert.equal("MOCK_PARAM_PROPERTY_VALUE", testObj.mockProperty)
      )
    )
    suite("setDefaultPersister", ()->
      test("settingDefaultPersisterUsesDefaultPersisterInParameterlessBuildPersister", ()->
        #implement test
        class testPersister
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerPersister("testPersister",testPersister)
        Factory.setDefaultPersister("testPersister")
        testObj = Factory.buildPersister()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
    )
    suite("registerTransport", ()->
      test("Not registering makes default BuildTransport throw", ()->
        chai.assert.throws(()->
          Factory.buildTransport()
        )
      )
      test("Not Registering makes keyed buildTransport throw", ()->
        chai.assert.throws(()->
          Factory.buildTransport("anything")
        )
      )

      test("Registering and building transport behaves same as registering and building persister", ()->
        #implement test
        factoryRes = {}
        testPersister=()->
          factoryRes

        testTransport=()->
          factoryRes

        Factory.registerPersister("testPersister",testPersister)
        testP = Factory.buildPersister("testPersister")
        Factory.registerTransport("testTransport",testTransport)
        testT = Factory.buildTransport("testTransport")
        chai.assert.equal(testP, testT)
      )
    )
    suite("setDefaultTransport", ()->
      test("Setting default transport uses default transport in parameterless buildTransport", ()->
        #implement test
        class testTransport
          constructor:()->
            @mockProperty="MOCK_VALUE"

        Factory.registerTransport("testTransport",testTransport)
        Factory.setDefaultTransport("testTransport")
        testObj = Factory.buildTransport()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )
    )
  )


)