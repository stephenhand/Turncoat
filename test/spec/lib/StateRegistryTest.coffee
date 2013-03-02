define(["isolate!lib/StateRegistry"], (StateRegistry)->
  #StateRegistryTest.coffee test file
  suite("StateRegistryTest", ()->
    suite("registerType", ()->
      test("registeringTypeAddsConstructorToRegistry", ()->
        class testGameStateType
          constructor:()->
            @mockProperty="MOCK_VALUE"

        StateRegistry.registerType("testGameStateType",testGameStateType)
        testObj = new StateRegistry["testGameStateType"]()
        chai.assert.equal("MOCK_VALUE", testObj.mockProperty)
      )

      test("constructingUnregisteredTypeThrows", ()->

        chai.assert.throws(()=>
          new StateRegistry["missingGameStateType"]()
        )
      )
    )
  )


)