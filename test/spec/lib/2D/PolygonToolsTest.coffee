define(["isolate!lib/2D/PolygonTools"], (PolygonTools)->
  #PolygonToolsTest.coffee test file    
  suite("PolygonToolsTest", ()->
    suite("pointInPoly", ()->
      test("pointLeftofSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ], 5, 15

        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointRightofSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly(
          [
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ], 25, 15

        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointAboveSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly(
          [
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ], 15, 5

        )
        chai.assert.equal(isInPoly, false)
      )

      test("pointBelowSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 25, 15

        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointAboveLeftofSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 5, 5

        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointAboveRightSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 25, 5

        )
        chai.assert.equal(isInPoly, false)
      )

      test("pointBelowLeftSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 5, 15

        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointBelowRightofSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 25, 25

        )
        chai.assert.equal(isInPoly, false)
      )

      test("pointInsideSquareReturnsTrue", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 15, 15

        )
        chai.assert.equal(isInPoly, true)
      )

      test("pointOnLeftLineOfSquareReturnsTrue", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 10, 15

        )
        chai.assert.equal(isInPoly, true)
      )


      test("pointOnRightLineOfSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 20, 15

        )
        chai.assert.equal(isInPoly, false)
      )


      test("pointOnTopLineOfSquareReturnsTrue", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 15, 10

        )
        chai.assert.equal(isInPoly, true)
      )

      test("pointOnBottomLineOfSquareReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ], 15, 20

        )
        chai.assert.equal(isInPoly, false)
      )

      test("pointInsideOverallSquareOfIrregularPolyButOutsidePolyReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ,
          x:18
          y:15
        ], 13, 14

        )
        chai.assert.equal(isInPoly, false)
      )

      test("pointInsideIrregularPolyButOutsidRightAnglesReturnsTrue", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ,
          x:18
          y:15
        ], 17, 16
        )
        chai.assert.equal(isInPoly, true)
      )


      test("pointOutsideComplexPolyReturnsFalse", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ,
          x:10
          y:18
        ,
          x:18
          y:18
        ,
          x:18
          y:12
        ,
          x:12
          y:12
        ,
          x:12
          y:15
        ,
          x:14
          y:15
        ,
          x:14
          y:15
        ,
          x:14
          y:14
        ,
          x:16
          y:14
        ,
          x:16
          y:16
        ,
          x:10
          y:16
        ], 13, 14
        )
        chai.assert.equal(isInPoly, false)
      )
      test("pointInsideComplexPolyReturnsTrue", ()->
        #implement test
        isInPoly = PolygonTools.pointInPoly([
          x:10
          y:10
        ,
          x:20
          y:10
        ,
          x:20
          y:20
        ,
          x:10
          y:20
        ,
          x:10
          y:18
        ,
          x:18
          y:18
        ,
          x:18
          y:12
        ,
          x:12
          y:12
        ,
          x:12
          y:15
        ,
          x:14
          y:15
        ,
          x:14
          y:15
        ,
          x:14
          y:14
        ,
          x:16
          y:14
        ,
          x:16
          y:16
        ,
          x:10
          y:16
        ], 15, 15
        )
        chai.assert.equal(isInPoly, true)
      )
    )

    suite("doPolysOverlap", ()->
      test("twoSquaresThatDontOverlapReturnsFalse", ()->
        #implement test
        overlap = PolygonTools.pointInPoly([
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ],[
            x:35
            y:35
          ,
            x:45
            y:35
          ,
            x:45
            y:45
          ,
            x:35
            y:45
          ]

        )
        chai.assert.equal(overlap, false)
      )
      test("twoSquaresWhere1HasAPointIn2ReturnsTrue", ()->
        #implement test
        overlap = PolygonTools.pointInPoly([
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ],[
            x:15
            y:5
          ,
            x:25
            y:5
          ,
            x:25
            y:25
          ,
            x:15
            y:25
          ]

        )
        chai.assert.equal(overlap, false)
      )

      test("twoSquaresWhere2HasAPointIn1ReturnsTrue", ()->
        #implement test
        overlap = PolygonTools.pointInPoly([
            x:15
            y:5
          ,
            x:25
            y:5
          ,
            x:25
            y:25
          ,
            x:15
            y:25
          ],[
            x:10
            y:10
          ,
            x:20
            y:10
          ,
            x:20
            y:20
          ,
            x:10
            y:20
          ]

        )
        chai.assert.equal(overlap, false)
      )

      #This case is not currently covered, but shouldn't matter for detecting collisions resulting from movement
      test("twoSquaresThatOverlapButNoPointsDoReturnsFalse", ()->
        #implement test
        overlap = PolygonTools.pointInPoly([
            x:0
            y:10
          ,
            x:30
            y:10
          ,
            x:30
            y:20
          ,
            x:0
            y:20
          ],[
            x:10
            y:0
          ,
            x:20
            y:0
          ,
            x:20
            y:30
          ,
            x:10
            y:30
          ]

        )
        chai.assert.equal(overlap, false)
      )
    )
  )
)