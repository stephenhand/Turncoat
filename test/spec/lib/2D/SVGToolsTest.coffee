require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!lib/2D/SVGTools", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(SVGTools, m, o, a, jm, v)->
  mocks = window.mockLibrary["lib/2D/SVGTools"]
  suite("SVGTools", ()->

    suite("pixelCoordsToSVGUnits", ()->
      element = null
      setup(()->
        element =
          getBoundingClientRect : ()->
            width:500
            height:1000
          getBBox : ()->
            height:50
            width:50

      )
      test("returns object with x and y set to input values multiplied by ration of client bounding box to bounding box of element", ()->
        a(SVGTools.pixelCoordsToSVGUnits(element,350,350), m.allOf(m.hasMember("x",35),m.hasMember("y",17.5)))
      )
      test("still calculates coordinates outside element", ()->
        a(SVGTools.pixelCoordsToSVGUnits(element,1350,1350), m.allOf(m.hasMember("x",135),m.hasMember("y",67.5)))
      )
      test("still calculates negative coordinates", ()->
        a(SVGTools.pixelCoordsToSVGUnits(element,-350,-350), m.allOf(m.hasMember("x",-35),m.hasMember("y",-17.5)))
      )
      test("treats null x or y as zero", ()->
        a(SVGTools.pixelCoordsToSVGUnits(element,null,350), m.allOf(m.hasMember("x",0),m.hasMember("y",17.5)))
        a(SVGTools.pixelCoordsToSVGUnits(element,350,null), m.allOf(m.hasMember("x",35),m.hasMember("y",0)))
      )
      test("throws if element does not have getBBox method", ()->
        delete element.getBBox
        a(()->
          SVGTools.pixelCoordsToSVGUnits(element,350,350)
        ,
          m.raisesAnything()
        )
      )
      test("throws if element does not have getBoundingClientRect method", ()->
        delete element.getBoundingClientRect
        a(()->
          SVGTools.pixelCoordsToSVGUnits(element,350,350)
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

