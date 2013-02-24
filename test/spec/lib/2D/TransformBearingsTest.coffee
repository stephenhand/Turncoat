define(["isolate!lib/2D/TransformBearings"], (TransformBearings)->
  #TransformBearingsTest.coffee test file    
  suite("TransformBearingsTest", ()->
    suite("BearingAndDistanceToVector", ()->
      test("0BearingTransformsDistanceToNegativeYVector", ()->
        #implement test
        chai.assert.equal(TransformBearings.bearingAndDistanceToVector(0, 23).y, -23)
      )
      test("90BearingTransformsDistanceToNegativeXVector", ()->
        #implement test
        chai.assert.equal(TransformBearings.bearingAndDistanceToVector(90, 23).x, 23)
      )
      test("180BearingTransformsDistanceToPositiveYVector", ()->
        #implement test
        chai.assert.equal(TransformBearings.bearingAndDistanceToVector(180, 23).y, 23)
      )
      test("270BearingTransformsDistanceToPositiveVector", ()->
        #implement test
        chai.assert.equal(TransformBearings.bearingAndDistanceToVector(270, 23).x, -23)
      )
    )
  )
)