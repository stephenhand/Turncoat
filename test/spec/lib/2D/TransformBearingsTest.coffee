define(["isolate!lib/2D/TransformBearings", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (TransformBearings, m, o, a, jm, v)->
  #TransformBearingsTest.coffee test file    
  suite("TransformBearingsTest", ()->
    suite("BearingAndDistanceToVector", ()->
      test("0DistanceReturns0Vector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(180, 0)
        a(vector.x, 0)
        a(vector.y, 0)
      )
      test("0BearingTransformsDistanceToNegativeYVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(0, 23)
        a(vector.x, 0)
        a(vector.y, -23)
      )
      test("90BearingTransformsDistanceToNegativeXVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(90, 23)
        a(vector.x, 23)
        a(vector.y, 0)
      )
      test("180BearingTransformsDistanceToPositiveYVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(180, 23)
        a(vector.x, 0)
        a(vector.y, 23)
      )
      test("270BearingTransformsDistanceToPositiveVector", ()->
        #implement test
        vector = TransformBearings.bearingAndDistanceToVector(270, 23)
        a(Math.round(vector.x), -23)
        a(Math.round(vector.y), 0)
      )
      test("141at45bearingGivesApprox100xneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(45, 141)
        a(Math.round(vector.x), 100)
        a(Math.round(vector.y), -100)
      )
      test("141at135bearingGivesApprox100x100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(135, 141)
        a(Math.round(vector.x), 100)
        a(Math.round(vector.y), 100)
      )
      test("141at225bearingGivesApproxneg100x100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(225, 141)
        a(Math.round(vector.x), -100)
        a(Math.round(vector.y), 100)
      )
      test("141at315bearingGivesApproxneg100xneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(315, 141)
        a(Math.round(vector.x), -100)
        a(Math.round(vector.y), -100)
      )
      test("141at405bearingGivesApprox100xneg100yVector", ()->
        vector = TransformBearings.bearingAndDistanceToVector(405, 141)
        a(Math.round(vector.x), 100)
        a(Math.round(vector.y), -100)
      )
    )
    suite("vectorToBearingAndDistance", ()->

      test("0VectorReturns0BearingAndDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:0})
        a(bAndD.bearing, 0)
        a(bAndD.distance, 0)
      )
      test("negYand0XVectorReturns0bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:-45})
        a(bAndD.bearing, 0)
        a(bAndD.distance, 45)
      )
      test("0YandPosXVectorReturns90bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:45,y:0})
        a(bAndD.bearing, 90)
        a(bAndD.distance, 45)
      )
      test("posYand0XVectorReturns180bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:0,y:45})
        a(bAndD.bearing, 180)
        a(bAndD.distance, 45)
      )
      test("0YandPosXVectorReturns270bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-45,y:0})
        a(bAndD.bearing, 270)
        a(bAndD.distance, 45)
      )
      test("neg2000Yand200XVectorReturns45bearingAnd282Distance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:200,y:-200})
        a(bAndD.bearing, 45)
        a(Math.round(bAndD.distance), 283)
      )
      test("200Yand200XVectorReturns135bearingAnd282Distance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:200,y:200})
        a(bAndD.bearing, 135)
        a(Math.round(bAndD.distance), 283)
      )
      test("200Yandneg200XVectorReturns225bearingAndYDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-200,y:200})
        a(bAndD.bearing, 225)
        a(Math.round(bAndD.distance), 283)
      )
      test("neg200YandnegXVectorReturns315bearingAndXDistance", ()->
        bAndD = TransformBearings.vectorToBearingAndDistance({x:-200,y:-200})
        a(bAndD.bearing, 315)
        a(Math.round(bAndD.distance), 283)
      )

    )
    suite("rotateBearing", ()->
      test("Start not a number - throws", ()->
        a(()->
          TransformBearings.rotateBearing("315", 90)
        , m.raisesAnything()
        )
      )
      test("Rotation not a number - throws", ()->
        a(()->
          TransformBearings.rotateBearing(315, "90")
        , m.raisesAnything()
        )
      )
      test("Zero rotation - leaves bearing unmodified", ()->
        a(TransformBearings.rotateBearing(150.5, 0), 150.5)
      )
      test("Zero rotation, start out of normal bearing range - mods to between 0 - 360", ()->

        a(TransformBearings.rotateBearing(750, 0), 30)
      )
      test("Clockwise rotation from under 180 to under 180 - should simply add rotation value", ()->
        a(TransformBearings.rotateBearing(50, 90), 140)
        a(TransformBearings.rotateBearing(50.5, 90.2), 140.7)
      )
      test("Clockwise rotation from under 180 to over 180 - should simply add rotation value", ()->
        a(TransformBearings.rotateBearing(150, 90), 240)
        a(TransformBearings.rotateBearing(150.5, 90.2), 240.7)
      )
      test("Clockwise rotation from over 180 to over 180 - should simply add rotation value", ()->
        a(TransformBearings.rotateBearing(250, 90), 340)
        a(TransformBearings.rotateBearing(250.5, 90.2), 340.7)
      )
      test("Clockwise rotation from over 180 to under 180 - should be bearing from zero", ()->
        a(TransformBearings.rotateBearing(315, 90), 45)
        a(TransformBearings.rotateBearing(315.5, 90.2), 45.7)
      )
      test("Clockwise rotation over 360 degrees - should calculate correct final bearing", ()->
        a(TransformBearings.rotateBearing(50, 810), 140)
        a(TransformBearings.rotateBearing(50.1, 810.1), 140.2)
      )
      test("Anticlockwise rotation from under 180 to under 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotateBearing(140, -90), 50)
        a(TransformBearings.rotateBearing(140.3, -90.2), 50.1)
      )
      test("Anticlockwise rotation from under 180 to over 180 - should correct from negative bearing to one deducted from 360", ()->
        a(TransformBearings.rotateBearing(40, -90), 310)
        a(TransformBearings.rotateBearing(40.3, -90.2), 310.1)
      )
      test("Anticlockwise rotation from over 180 to over 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotateBearing(315, -90), 225)
        a(TransformBearings.rotateBearing(315.5, -90.2), 225.3)
      )
      test("Anticlockwise rotation from over 180 to under 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotateBearing(215, -90), 125)
        a(TransformBearings.rotateBearing(215.1, -90.2), 124.9)
      )
      test("Anticlockwise rotation over 360 degrees - should calculate correct final bearing", ()->

        a(TransformBearings.rotateBearing(215, -810), 125)
        a(TransformBearings.rotateBearing(215.1, -810.2), 124.9)
      )
    )
    suite("rotationBetweenBearings", ()->
      test("Start not a number - throws", ()->
        a(()->
          TransformBearings.rotationBetweenBearings("315", 90)
        , m.raisesAnything()
        )
      )
      test("End not a number - throws", ()->
        a(()->
          TransformBearings.rotationBetweenBearings(315, "90")
        , m.raisesAnything()
        )
      )
      test("Same bearings - returns zero", ()->
        a(TransformBearings.rotationBetweenBearings(150.5, 150.5), 0)
      )
      test("Same bearings out of normal bearing range - returns zero", ()->

        a(TransformBearings.rotationBetweenBearings(750, 750), 0)
      )
      test("Going clockwise from under 180 to under 180 - should simply return difference", ()->
        a(TransformBearings.rotationBetweenBearings(50, 90), 40)
        a(TransformBearings.rotationBetweenBearings(50.5, 90.2), 39.7)
      )
      test("Going clockwise from under 180 to over 180 - should simply return difference", ()->
        a(TransformBearings.rotationBetweenBearings(150, 240), 90)
        a(TransformBearings.rotationBetweenBearings(150.5, 240.7), 90.2)
      )
      test("Going clockwise from over 180 to over 180 - should simply return difference", ()->
        a(TransformBearings.rotationBetweenBearings(250, 340), 90)
        a(TransformBearings.rotationBetweenBearings(250.5, 340.7), 90.2)
      )
      test("Going clockwise from over 180 to under 180 - should be rotation crossing over zero", ()->
        a(TransformBearings.rotationBetweenBearings(315, 45), 90)
        a(TransformBearings.rotationBetweenBearings(315.5, 45.7), 90.2)
      )
      test("Going clockwise over 360 degrees - should calculate minimum rotations between proper bearings", ()->
        a(TransformBearings.rotationBetweenBearings(50, 780), 10)
        a(TransformBearings.rotationBetweenBearings(50.1, 780.2), 10.1)
      )
      test("Going anticlockwise from under 180 to under 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotationBetweenBearings(140, 50), -90)
        a(TransformBearings.rotationBetweenBearings(140.3, 50.1), m.closeTo(-90.2, 0.01))
      )
      test("Going anticlockwise from under 180 to over 180 - should correct from negative bearing to one deducted from 360", ()->
        a(TransformBearings.rotationBetweenBearings(40, 310), -90)
        a(TransformBearings.rotationBetweenBearings(40.3, 310.1), m.closeTo(-90.2, 0.01))
      )
      test("Going anticlockwise from over 180 to over 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotationBetweenBearings(315, 225), -90)
        a(TransformBearings.rotationBetweenBearings(315.5, 225.3), m.closeTo(-90.2, 0.01))
      )
      test("Going anticlockwise from over 180 to under 180 - should simply add negative rotation value", ()->
        a(TransformBearings.rotationBetweenBearings(215, 125), -90)
        a(TransformBearings.rotationBetweenBearings(215.1, 124.9), m.closeTo(-90.2, 0.01))
      )
      test("Going anticlockwise over 360 degrees - should calculate correct final bearing", ()->

        a(TransformBearings.rotationBetweenBearings(15, -720), -15)
        a(TransformBearings.rotationBetweenBearings(15.1, -720.2),  m.closeTo(-15.3, 0.01))
      )
    )
    suite("intersectionVectorOf2PointsWithBearings", ()->
      test("Either point missing - throws", ()->
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            y:30
            bearing:45
          ,
            x:1
            y:2
          )
        , m.raisesAnything()
        )
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            y:30
          ,
            x:1
            y:2
            bearing:30
          )
        ,
          m.raisesAnything()
        )
      )
      test("Either coordinate missing on either point - throws", ()->
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            y:30
            bearing:45
          ,
            x:1
            y:2
            bearing:30
          )
        ,
          m.raisesAnything()
        )
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            bearing:45
          ,
            x:1
            y:2
            bearing:30
          )
        , m.raisesAnything()
        )
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            y:30
            bearing:45
          ,
            y:2
            bearing:30
          )
        ,
          m.raisesAnything()
        )
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            y:30
            bearing:45
          ,
            x:1
            bearing:30
          )
        ,
          m.raisesAnything()
        )
      )
      test("Bearing missing on either point - throws", ()->
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            y:30
            bearing:45
          ,
            x:1
            y:2
          )
        ,
          m.raisesAnything()
        )
        a(()->
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:25
            y:30
          ,
            x:1
            y:2
            bearing:30
          )
        ,
          m.raisesAnything()
        )
      )
      test("Finds a correct intersection point of 2 points at simple right angles", ()->
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:0
          y:0
          bearing:90
        ,
          x:4
          y:3
          bearing:0
        )
        a(p.x, m.closeTo(4,0.01))
        a(p.y, 0)
      )

      test("Finds a correct intersection point of 2 points at right angles at all rotations", ()->
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:5
          y:10
          bearing:0
        ,
          x:20
          y:5
          bearing:270
        )
        a(p.x, 0)
        a(p.y, m.closeTo(-5, 0.01))
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:20
          y:10
          bearing:0
        ,
          x:5
          y:5
          bearing:90
        )
        a(p.x, 0)
        a(p.y, m.closeTo(-5, 0.01))
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:5
          y:5
          bearing:180
        ,
          x:20
          y:10
          bearing:270
        )
        a(p.x, 0)
        a(p.y, m.closeTo(5, 0.01))
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:20
          y:5
          bearing:180
        ,
          x:5
          y:10
          bearing:90
        )
        a(p.x, 0)
        a(p.y, m.closeTo(5, 0.01))

        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:5
          y:10
          bearing:90
        ,
          x:20
          y:5
          bearing:180
        )
        a(p.x, m.closeTo(15, 0.01))
        a(p.y, 0)
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:5
          y:5
          bearing:90
        ,
          x:20
          y:10
          bearing:0
        )
        a(p.x, m.closeTo(15, 0.01))
        a(p.y, 0)
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:20
          y:10
          bearing:270
        ,
          x:5
          y:5
          bearing:180
        )
        a(p.x, m.closeTo(-15, 0.01))
        a(p.y, 0)
        p = TransformBearings.intersectionVectorOf2PointsWithBearings(
          x:20
          y:5
          bearing:270
        ,
          x:5
          y:10
          bearing:0
        )
        a(p.x, m.closeTo(-15, 0.01))
        a(p.y, 0)
      )
    )
  )
)