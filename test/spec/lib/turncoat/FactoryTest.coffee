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

    )
    suite("registerStateMarshaller", ()->
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

  )


)