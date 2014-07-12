define(["isolate!lib/turncoat/TypeRegistry"], (TypeRegistry)->
  #TypeRegistryTest.coffee test file
  suite("TypeRegistry", ()->
    suite("registerType", ()->
      test("registeringTypeAddsConstructorToRegistry", ()->
        class testGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"

        testGameStateType.toString = ()->
          "ME AS A STRING!"
        TypeRegistry.registerType("testGameStateType",testGameStateType)
        testObj = new TypeRegistry["testGameStateType"]()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )

      test("constructingUnregisteredTypeThrows", ()->

        chai.assert.throws(()=>
          new TypeRegistry["missingGameStateType"]()
        )
      )
      test("registeringTypePopulatesReverseRegistry", ()->
        class testGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"

        TypeRegistry.registerType("testGameStateType",testGameStateType)
        testType = TypeRegistry.reverseLookup(testGameStateType)
        chai.assert.equal(testType, "testGameStateType")
      )

      test("lookingUpUnregisteredConstructorReturnsUndefined", ()->
        class anotherGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"
        lookup = TypeRegistry.reverseLookup(anotherGameStateType)
        chai.assert.isUndefined(lookup)
      )
    )
  )


)