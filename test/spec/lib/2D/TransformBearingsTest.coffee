define(["isolate!lib/2D/TransformBearings"], (TransformBearings)->
  #TransformBearingsTest.coffee test file    
  suite("TransformBearingsTest", ()->
    suite("BearingAndDistanceToVector", ()->
      test("0DistanceReturns0Vector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(180, 0)
        chai.assert.equal(vector.x, 0)
        chai.assert.equal(vector.y, 0)
      )
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
      test("141at45bearingGivesApprox100xneg100yVector", ()->
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
      test("141at405bearingGivesApprox100xneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(405, 141)
        chai.assert.equal(Math.round(vector.x), 100)
        chai.assert.equal(Math.round(vector.y), -100)
      )
    )
    suite("vectorToBearingAndDistance", ()->

      test("0VectorReturns0BearingAndDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:0})
        chai.assert.equal(bAndD.bearing, 0)
        chai.assert.equal(bAndD.distance, 0)
      )
      test("negYand0XVectorReturns0bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:-45})
        chai.assert.equal(bAndD.bearing, 0)
        chai.assert.equal(bAndD.distance, 45)
      )
      test("0YandPosXVectorReturns90bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:45,y:0})
        chai.assert.equal(bAndD.bearing, 90)
        chai.assert.equal(bAndD.distance, 45)
      )
      test("posYand0XVectorReturns180bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:45})
        chai.assert.equal(bAndD.bearing, 180)
        chai.assert.equal(bAndD.distance, 45)
      )
      test("0YandPosXVectorReturns270bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-45,y:0})
        chai.assert.equal(bAndD.bearing, 270)
        chai.assert.equal(bAndD.distance, 45)
      )
      test("neg2000Yand200XVectorReturns45bearingAnd282Distance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:200,y:-200})
        chai.assert.equal(bAndD.bearing, 45)
        chai.assert.equal(Math.round(bAndD.distance), 283)
      )
      test("200Yand200XVectorReturns135bearingAnd282Distance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:200,y:200})
        chai.assert.equal(bAndD.bearing, 135)
        chai.assert.equal(Math.round(bAndD.distance), 283)
      )
      test("200Yandneg200XVectorReturns225bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-200,y:200})
        chai.assert.equal(bAndD.bearing, 225)
        chai.assert.equal(Math.round(bAndD.distance), 283)
      )
      test("neg200YandnegXVectorReturns315bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-200,y:-200})
        chai.assert.equal(bAndD.bearing, 315)
        chai.assert.equal(Math.round(bAndD.distance), 283)
      )

    )
  )
)