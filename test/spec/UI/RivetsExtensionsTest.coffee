define(['isolate!RivetsExtensions'], ('RivetsExtensions')->
  suite("RivetsExtensionsTest", ()->
    suite("someMethod", ()->
      test("someTest", ()->
        chai.assert.true()
      )
    )
  )

)

