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
      test("PathStringWithMultiplyNestedPathsOnQueryString_CreatesNestedSubRoutesPerPath", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE?OTHER_MODAL=CUP/OF/TEA?NESTED=PINCH/O/SALT;;&CORNER_MODAL=/DIGESTIVE/BISCUIT")
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

        chai.assert.equal(r.subRoutes.CORNER_MODAL.parts.length, 2)
        chai.assert.equal(r.subRoutes.CORNER_MODAL.parts[0], "DIGESTIVE")
        chai.assert.equal(r.subRoutes.CORNER_MODAL.parts[1], "BISCUIT")
        chai.assert.isTrue(r.subRoutes.CORNER_MODAL.absolute)
      )
      test("TrailingSemiColon_DoesntAffectResult", ()->
        r = new Route("CHEESE/ON/TOAST?MOCK_MODAL=/BROWN/SAUCE?OTHER_MODAL=CUP/OF/TEA?NESTED=PINCH/O/SALT;&CORNER_MODAL=/DIGESTIVE/BISCUIT;")
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

      test("NonString_CreatesRouteWithEmptyParts", ()->
        r = new Route({})
        chai.assert.equal(r.parts.length,0)
      )
    )
    suite("toString",()->
      test("EmptyPartsArrayNoSubRoutesObject_EmptyString", ()->
        r = new Route()
        chai.assert.equal("", r.toString())
      )
      test("SingleItemPartsArrayNoSubRoutesObject_ItemAsString", ()->
        r = new Route()
        r.parts = ["CHEESE"]
        chai.assert.equal("CHEESE", r.toString())
      )
      test("MultipleItemPartsArrayNoSubRoutesObject_ItemsAsPath", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        chai.assert.equal("CHEESE/ON/TOAST", r.toString())
      )
      test("AbsoluteFlagSet_PrependsSeparator", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.absolute = true
        chai.assert.equal("/CHEESE/ON/TOAST", r.toString())
      )
      test("EmptySubRoutesObject_AppendsQuerySemiColon", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.subRoutes = {}
        chai.assert.equal("CHEESE/ON/TOAST?;", r.toString())
      )
      test("SubRoutesObjectPopulatedWithRoutes_AppendsQueryWithKeyValuePairsWithToStringResultAsValueEndingInSemiColon", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.subRoutes =
          SUBROUTE1:new Route()
          SUBROUTE2:new Route()
          SUBROUTE3:new Route()
        r.subRoutes.SUBROUTE1.parts = ["BROWN", "SAUCE"]
        r.subRoutes.SUBROUTE2.parts = ["DIGESTIVE", "BISCUIT"]
        r.subRoutes.SUBROUTE2.absolute = true
        r.subRoutes.SUBROUTE3.parts = ["CUP", "OF", "TEA"]
        chai.assert.equal("CHEESE/ON/TOAST?SUBROUTE1=BROWN/SAUCE&SUBROUTE2=/DIGESTIVE/BISCUIT&SUBROUTE3=CUP/OF/TEA;", r.toString())
      )
      test("SubRoutesObjectPopulatedWithNestedRoutes_Recurses", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.subRoutes =
          SUBROUTE1:new Route()
          SUBROUTE3:new Route()
        r.subRoutes.SUBROUTE1.parts = ["BROWN", "SAUCE"]
        r.subRoutes.SUBROUTE1.subRoutes = {}
        r.subRoutes.SUBROUTE1.subRoutes.SUBROUTE2=new Route()
        r.subRoutes.SUBROUTE1.subRoutes.SUBROUTE2.parts = ["DIGESTIVE", "BISCUIT"]
        r.subRoutes.SUBROUTE1.subRoutes.SUBROUTE2.absolute = true
        r.subRoutes.SUBROUTE3.parts = ["CUP", "OF", "TEA"]
        chai.assert.equal("CHEESE/ON/TOAST?SUBROUTE1=BROWN/SAUCE?SUBROUTE2=/DIGESTIVE/BISCUIT;&SUBROUTE3=CUP/OF/TEA;", r.toString())
      )
      test("SubRoutesObjectPopulatedWithRoutesAndOtherData_IgnoresOtherData", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.subRoutes =
          SUBROUTE1:new Route()
          A:{}
          SUBROUTE2:new Route()
          B:{}
          SUBROUTE3:new Route()
          C:{}
        r.subRoutes.SUBROUTE1.parts = ["BROWN", "SAUCE"]
        r.subRoutes.SUBROUTE2.parts = ["DIGESTIVE", "BISCUIT"]
        r.subRoutes.SUBROUTE2.absolute = true
        r.subRoutes.SUBROUTE3.parts = ["CUP", "OF", "TEA"]
        chai.assert.equal("CHEESE/ON/TOAST?SUBROUTE1=BROWN/SAUCE&SUBROUTE2=/DIGESTIVE/BISCUIT&SUBROUTE3=CUP/OF/TEA;", r.toString())
      )
      test("SubRoutesWithNoRouteProperties_AppendsQuerySemiColon", ()->
        r = new Route()
        r.parts = ["CHEESE","ON","TOAST"]
        r.subRoutes =
          A:{}
          B:{}
          C:{}
        chai.assert.equal("CHEESE/ON/TOAST?;", r.toString())
      )
    )
  )


)

