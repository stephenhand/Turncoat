define(["isolate!lib/2D/TransformBearings"], (TransformBearings)->
  #TransformBearingsTest.coffee test file    
  suite("TransformBearingsTest", ()->
    suite("BearingAndDistanceToVector", ()->
      test("0BearingTransformsDistanceToNegativeYVector", ()->
        #implement test
        chai.assert.equal(TransformBearings.bearingAndDistanceToVector(0, 23).y, -23)
      )
    )
  )
)