define(["isolate!lib/turncoat/StateRegistry"], (StateRegistry)->
  #StateRegistryTest.coffee test file
  suite("StateRegistryTest", ()->
    suite("registerType", ()->
      test("registeringTypeAddsConstructorToRegistry", ()->
        class testGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"

        testGameStateType.toString = ()->
          "ME AS A STRING!"
        StateRegistry.registerType("testGameStateType",testGameStateType)
        testObj = new StateRegistry["testGameStateType"]()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )

      test("constructingUnregisteredTypeThrows", ()->

        chai.assert.throws(()=>
          new StateRegistry["missingGameStateType"]()
        )
      )
      test("registeringTypePopulatesReverseRegistry", ()->
        class testGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"

        StateRegistry.registerType("testGameStateType",testGameStateType)
        testType = StateRegistry.reverseLookup(testGameStateType)
        chai.assert.equal(testType, "testGameStateType")
      )

      test("lookingUpUnregisteredConstructorReturnsUndefined", ()->
        class anotherGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"
        lookup = StateRegistry.reverseLookup(anotherGameStateType)
        chai.assert.isUndefined(lookup)
      )
    )
  )


)