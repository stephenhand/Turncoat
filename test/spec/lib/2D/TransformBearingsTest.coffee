define(["isolate!lib/2D/TransformBearings"], (TransformBearings)->
  #TransformBearingsTest.coffee test file    
  suite("TransformBearingsTest", ()->
    suite("BearingAndDistanceToVector", ()->
      test("0BearingTransformsDistanceToNegativeYVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(0, 23)
        chai.assert.equal(vector.x, 0)
        chai.assert.equal(vector.y, -23)
      )
      test("90BearingTransformsDistanceToNegativeXVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(90, 23)
        chai.assert.equal(vector.x, 23)
        chai.assert.equal(vector.y, 0)
      )
      test("180BearingTransformsDistanceToPositiveYVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(180, 23)
        chai.assert.equal(vector.x, 0)
        chai.assert.equal(vector.y, 23)
      )
      test("270BearingTransformsDistanceToPositiveVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(270, 23)
        chai.assert.equal(Math.round(vector.x), -23)
        chai.assert.equal(Math.round(vector.y), 0)
      )
      test("141at45bearingGives100Approxxneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(45, 141)
        chai.assert.equal(Math.round(vector.x), 100)
        chai.assert.equal(Math.round(vector.y), -100)
      )
      test("141at135bearingGivesApprox100x100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(135, 141)
        chai.assert.equal(Math.round(vector.x), 100)
        chai.assert.equal(Math.round(vector.y), 100)
      )
      test("141at225bearingGivesApproxneg100x100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(225, 141)
        chai.assert.equal(Math.round(vector.x), -100)
        chai.assert.equal(Math.round(vector.y), 100)
      )
      test("141at315bearingGivesApproxneg100xneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(315, 141)
        chai.assert.equal(Math.round(vector.x), -100)
        chai.assert.equal(Math.round(vector.y), -100)
      )
    )
  )
)