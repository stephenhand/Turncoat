define(["isolate!UI/routing/Route"], (Route)->
  suite("Route", ()->
    suite("constructor", ()->
      test("SinglePartRelativePathString_CreatespartsAsSingleItemArrayAbsoluteFlagNotSet", ()->
        r = new Route("CHEESE")
        chai.assert.equal(r.parts.length, 1)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.isUndefined(r.absolute)

      )
      test("MultiPartRelativePathString_CreatespartsAsMultiItemArrayAbsoluteFlagNotSet", ()->
        r = new Route("CHEESE/ON/TOAST")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")
        chai.assert.isUndefined(r.absolute)
      )
      test("MultiPartAbsolutePathString_CreatespartsAsMultiItemArrayAbsoluteFlagSetTrue", ()->
        r = new Route("/CHEESE/ON/TOAST")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")
        chai.assert.isTrue(r.absolute)
      )
      test("MultiPartRelativePathStringWithSinglePathOnQueryString_AlsoCreatesQueryStringPathAsSubRouteNamedAsKey", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=BROWN")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")
        chai.assert.instanceOf(r.subRoutes.MOCK_MODAL, Route)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 1)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
      )
      test("MultiPartRelativePathStringWithMultiPathOnQueryString_AlsoCreatesQueryStringPathAsSubRouteNamedAsKey", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=BROWN/SAUCE")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")

        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[1], "SAUCE")
      )
      test("PathStringWithAbsolutePathOnQueryString_CreatesSubRouteWithAbsoluteFlagSet", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")

        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[1], "SAUCE")
        chai.assert.isTrue(r.subRoutes.MOCK_MODAL.absolute)
      )
      test("PathStringWithMultiplePathsOnQueryString_CreatesSubRoutePerPath", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE&OTHER_MODAL=CUP/OF/TEA")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")

        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[1], "SAUCE")
        chai.assert.isTrue(r.subRoutes.MOCK_MODAL.absolute)

        chai.assert.equal(r.subRoutes.OTHER_MODAL.parts.length, 3)
        chai.assert.equal(r.subRoutes.OTHER_MODAL.parts[0], "CUP")
        chai.assert.equal(r.subRoutes.OTHER_MODAL.parts[1], "OF")
        chai.assert.equal(r.subRoutes.OTHER_MODAL.parts[2], "TEA")
        chai.assert.isUndefined(r.subRoutes.OTHER_MODAL.absolute)
      )
      test("PathStringWithNestedPathsOnQueryString_CreatesNestedSubRoutesPerPath", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE?OTHER_MODAL=CUP/OF/TEA")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")

        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[1], "SAUCE")
        chai.assert.isTrue(r.subRoutes.MOCK_MODAL.absolute)

        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts.length, 3)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[0], "CUP")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[1], "OF")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[2], "TEA")
        chai.assert.isUndefined(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.absolute)
      )
      test("PathStringWithMultiplyNestedPathsOnQueryString_CreatesNestedSubRoutesPerPath", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE?OTHER_MODAL=CUP/OF/TEA?NESTED=PINCH/O/SALT;&CORNER_MODAL=/DIGESTIVE/BISCUIT")
        chai.assert.equal(r.parts.length, 3)
        chai.assert.equal(r.parts[0], "CHEESE")
        chai.assert.equal(r.parts[1], "ON")
        chai.assert.equal(r.parts[2], "TOAST")

        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[0], "BROWN")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.parts[1], "SAUCE")
        chai.assert.isTrue(r.subRoutes.MOCK_MODAL.absolute)

        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts.length, 3)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[0], "CUP")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[1], "OF")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.parts[2], "TEA")
        chai.assert.isUndefined(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.absolute)

        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.subRoutes.NESTED.parts.length, 3)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.subRoutes.NESTED.parts[0], "PINCH")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.subRoutes.NESTED.parts[1], "O")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.subRoutes.NESTED.parts[2], "SALT")
        chai.assert.isUndefined(r.subRoutes.MOCK_MODAL.subRoutes.OTHER_MODAL.absolute)

        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.CORNER_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.CORNER_MODAL.parts[0], "DIGESTIVE")
        chai.assert.equal(r.subRoutes.MOCK_MODAL.subRoutes.CORNER_MODAL.parts[1], "BISCUIT")
        chai.assert.isTrue(r.subRoutes.MOCK_MODAL.subRoutes.CORNER_MODAL.absolute)
      )


      test("EmptyString_CreatesEmptyRoute", ()->
        r = new Route("")
        chai.assert.equal(r.parts.length, 1)
        chai.assert.equal(r.parts[0], "")
        chai.assert.isUndefined(r.subRoutes)
        chai.assert.isUndefined(r.absolute)
      )

      test("FowardSlash_CreatesEmptyRouteWithAbsoluteSet", ()->
        r = new Route("/")
        chai.assert.equal(r.parts.length, 1)
        chai.assert.equal(r.parts[0], "")
        chai.assert.isUndefined(r.subRoutes)
        chai.assert.isTrue(r.absolute)
      )

      test("QuestionMark_CreatesEmptyRouteWithEmptySubRouteCollection", ()->
        r = new Route("?")
        chai.assert.equal(r.parts.length, 1)
        chai.assert.equal(r.parts[0], "")
        subRoutes =0
        subRoutes++ for route of r.subRoutes
        chai.assert.equal(subRoutes, 0)
      )

      test("NoInput_CreatesRouteWithEmptyParts", ()->
        r = new Route()
        chai.assert.equal(r.parts.length,0)
      )

      test("NoNonString_CreatesRouteWithEmptyParts", ()->
        r = new Route({})
        chai.assert.equal(r.parts.length,0)
      )
    )
  )


)

