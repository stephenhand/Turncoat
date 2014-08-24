require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rivets","UI/rivets/Formatters", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        binders:{}
        formatters:{}
        config:
          adapter:
            read:JsMockito.mockFunction()
      JsMockito.when(stubRivets.config.adapter.read)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((obj, key)->
        obj[key]
      )

      stubRivets
    )
  )
  Isolate.mapAsFactory("sprintf","UI/rivets/Formatters", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret.func = actual
      ret
    )
  )
)

define(["isolate!UI/rivets/Formatters", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(Formatters, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/rivets/Formatters"]
  suite("Formatters", ()->

    suite("rotateCss", ()->
      test("formatsStringInputAsCssRotateDegrees", ()->
        a(Formatters.rotateCss("MOCK_VALUE"),"rotate(MOCK_VALUEdeg)")
      )
      test("formatsIntegerInputAsCssRotateDegrees", ()->
        a(Formatters.rotateCss(123),"rotate(123deg)")

      )
      test("formatsFloatingPointInputAsCssRotateDegrees", ()->
        a(Formatters.rotateCss(1.23),"rotate(1.23deg)")

      )
      test("formatsFloatingPointInputLosesTrailingZeros", ()->
        a(Formatters.rotateCss(1.2300),"rotate(1.23deg)")

      )
      test("usesValueOfInComplexObject", ()->
        a(Formatters.rotateCss(
          a:
            b:{}
          c:9
          valueOf:()->"VALUEOF_VAL"
        ),"rotate(VALUEOF_VALdeg)")
      )


    )
    suite("toggle", ()->
      test("toggle undefined and value undefined returns undefined", ()->
        a(Formatters.toggle(), m.nil())
      )
      test("toggle false value undefined returns undefined", ()->
        a(Formatters.toggle(false), m.nil())
      )
      test("toggleFalseValueDefinedReturnsUndefined", ()->
        a(Formatters.toggle(false,"MOCK_VALUE"), m.nil())
      )
      test("Input TrueValueUndefinedReturnsUndefined", ()->
        a(Formatters.toggle(true), m.nil())
      )
      test("Input TrueValueStringReturnsValue", ()->
        a(Formatters.toggle(true,"MOCK_VALUE"),"MOCK_VALUE")
      )
      test("toggleTrueValueObjectReturnsValue", ()->
        val={}
        a(Formatters.toggle(true,val),val)
      )
      test("toggleObjectValueUndefinedReturnsUndefined", ()->
        a(Formatters.toggle({}), m.nil())
      )
      test("toggleObjectValueStringReturnsValue", ()->
        a(Formatters.toggle({},"MOCK_VALUE"),"MOCK_VALUE")
      )
      test("toggleObjectValueObjectReturnsValue", ()->
        val={}
        a(Formatters.toggle({},val),val)
      )
      test("Input false and false value set - returns false value", ()->
        a(Formatters.toggle(false, "MOCK TRUE", "MOCK FALSE"),"MOCK FALSE")
      )
      test("Input true and only false value set - returns undefined", ()->
        a(Formatters.toggle(true, undefined,"MOCK_VALUE"), m.nil())
      )
    )
    suite("sprintf",()->
      origSPF = null
      setup(()->
        origSPF = mocks["sprintf"].func
        mocks["sprintf"].func=jm.mockFunction()
        JsMockito.when(mocks["sprintf"].func)(m.anything(),m.anything()).then(
          (a,b)->
            mask:a
            value:b
        )
      )
      teardown(()->
        origSPF = mocks["sprintf"].func = origSPF
      )
      test("Calls sprintf with first parameter as value and second parameter as pattern",()->
        ret = Formatters.sprintf("MOCK_VALUE","MOCK_MASK")
        a(ret.mask,"MOCK_MASK")
        a(ret.value,"MOCK_VALUE")
      )
    )
    suite("calc",()->
      suite("mask not defined", ()->
        test("returns unmodified input",()->
          a(Formatters.calc(13),13)
        )
        test("returns unmodified input even if input is not numeric or a backbone model",()->
          obj = {}
          a(Formatters.calc(obj),obj)
        )
      )
      suite("input is not a Backbone Model instance", ()->
        test("throws if input is not typeof number and no attribute arguments specified",()->
          a(()->
            Formatters.calc("MOCK_VALUE","12+%d")
          ,
            m.raisesAnything()
          )
        )
        test("still throws if input is parsable as a float",()->
          myEvilObject =
            valueOf:()->
              133.7
            toString:()->
              "133.7"
          a(()->
            Formatters.calc(myEvilObject,"12+%d")
          ,
            m.raisesAnything()
          )
        )
        test("throws if input is not defined",()->
          a(()->
            Formatters.calc(null,"%d*5")
          ,
            m.raisesAnything()
          )
        )
        test("substitutes input into mask using sprintf then returns result of expression",()->
          a(Formatters.calc(3,"%d*5"),15)
        )
      )
      suite("input is not a number", ()->
        model = null
        setup(()->
          model =
            propA:12
            propB:-16
            propC:20.5

        )
        test("No mask, returns unmodified input", ()->
          anyModel =
            prop:"val";
          a(Formatters.calc(anyModel),anyModel)
          a(Formatters.calc(anyModel),m.hasMember("prop","val"))
        )
        test("No attributes specified, no substitutions specified in mask - returns mask calculation", ()->
          a(Formatters.calc(model, "Math.floor(2.2*3)"),6)
        )
        test("No attributes specified, substitutions specified in mask - throws", ()->
          a(()->
            Formatters.calc(model, "Math.floor(%d*3)")
          ,m.raisesAnything())
        )
        test("Calls rivets adapter read method using input and attribute name", ()->
          Formatters.calc(model, "Math.floor(%d*3)", "propA")
          jm.verify(mocks["rivets"].config.adapter.read)(model,"propA")
        )
        test("Single attribute specified, single substitution specified in mask - calculates using value as read by rivets adapter of input using attribute name", ()->
          a(Formatters.calc(model, "Math.floor(%d*3)", "propA"),36)
        )
        test("Multiple attributes specified, same number of substitutions specified in mask - calculates substituting placeholders with attributes in order parameters are spoecified", ()->
          a(Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA"),-10)
        )
        test("Less substitutions specified than attributes - additional attributes ignored", ()->
          a(Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA", "propC"),-10)
        )
        test("More substitutions specified than attributes - throws", ()->
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB")
          ,m.raisesAnything())
        )
        test("Any attributes are non numeric - throws", ()->
          model.propB="THREE"
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA")
          ,m.raisesAnything())
        )
        test("Any attributes are missing - throws", ()->
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "notPropB", "propA")
          ,m.raisesAnything())
        )
        test("Any unused attributes are missing or non numeric - throws", ()->
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA", "notPropB")
          ,m.raisesAnything())
          model.propC="THREE"
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA", "propC")
          ,m.raisesAnything())
        )
        test("Rivets adapter throws - throws", ()->
          JsMockito.when(mocks["rivets"].config.adapter.read)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((obj, key)->
            throw new Error()
          )
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA")
          ,m.raisesAnything())
        )

      )
      test("allows Javascript method calls",()->
        a(Formatters.calc(3.123,"Math.floor(%d)"),3)
      )
      test("throws if invalid Javascript used in expression",()->
        a(()->
          Formatters.calc(13, "Matth.bugaboo(%d)")
        ,
          m.raisesAnything()
        )
      )
      test("allows input not to be used",()->
        a(Formatters.calc(3.123,"100/2"),50)
      )
      test("allows non numeric return types",()->
        a(Formatters.calc(3.123,"(100/2)+'hello'"),"50hello")
      )
    )
    suite("multiplier",()->
      origSPF = null
      setup(()->
        origSPF = mocks["sprintf"].func
        mocks["sprintf"].func=jm.mockFunction()
        JsMockito.when(mocks["sprintf"].func)(m.anything(),m.anything()).then(
          (a,b)->
            mask:a
            value:b
        )
      )
      teardown(()->
        origSPF = mocks["sprintf"].func = origSPF
      )
      test("decimalInputdecimalMultiplierNoMask_ReturnsMultiplied",()->
        ret = Formatters.multiplier("3.5", "2.5")
        a(ret,"8.75")
      )
      test("IntegerInputIntegerMultiplierNoMask_ReturnsMultiplied",()->
        ret = Formatters.multiplier("9","5")
        a(ret, "45")
      )
      test("decimalInputdecimalMultiplierMaskSetMask_ReturnsSPrintfResultUsingMultipliedWithMask",()->
        ret = Formatters.multiplier("3.5", "2.5" ,"MOCK_MASK")
        a(ret.mask,"MOCK_MASK")
        a(ret.value,"8.75")
      )
      test("NonNumericInputNoMask_ReturnsUnmodifiedInput",()->
        ret = Formatters.multiplier("NOT A NUMBER", "2.5" )
        a(ret,"NOT A NUMBER")
      )
      test("NonNumericMultiplierNoMask_ReturnsUnmodifiedInput",()->
        ret = Formatters.multiplier("2.5", "NOT A NUMBER")
        a(ret,"2.5")
      )
      test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
        ret = Formatters.multiplier("NOT A NUMBER", "2.5" ,"MOCK_MASK")
        a(ret.mask,"MOCK_MASK")
        a(ret.value,"NOT A NUMBER")
      )
      test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
        ret = Formatters.multiplier("2.5","NOT A NUMBER" ,"MOCK_MASK")
        a(ret.mask,"MOCK_MASK")
        a(ret.value,"2.5")
      )
    )

    suite("centroid", ()->
      input = null
      setup(()->
        input = new Backbone.Model()
      )
      suite("Input is backbone model with both attributes set", ()->
        test("Dimension  set as value - retuns position supplied minus half dimention", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:2
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 9)
        )
        test("Dimension set as zero - returns position supplied", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:0
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 10)
        )
        test("Dimension set as negative - returns position supplied plus half negative dimension", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:-2
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11)
        )
        test("Dimension not set - throws", ()->
          input.set(
            "MOCK_POS":10
          )
          a(
            ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Dimension not numeric - throws", ()->
          input.set(
            "MOCK_POS":10
            "MOCK_DIM":"NOT A NUMBER"
          )
          a(
            ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Dimension converts to numeric - converts", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:"-3"
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
        )
        test("Position undefined - throws", ()->
          input.set(
            MOCK_DIM:2
          )
          a(
            ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Position not numeric - throws", ()->
          input.set(
            MOCK_POS:"NOT A NUMBER"
            MOCK_DIM:2
          )
          a(
            ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Position converts to numeric - converts", ()->
          input.set(
            MOCK_POS:"12.5"
            MOCK_DIM:2
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
        )
        test("Position and Dimension converts to numeric - converts", ()->
          input.set(
            MOCK_POS:"12.5"
            MOCK_DIM:"2"
          )
          a(Formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
        )
      )
      test("Position not set - throws", ()->
        input.set(
          MOCK_POS:10
          MOCK_DIM:2
        )
        a(
          ()->Formatters.centroid(input, undefined,"MOCK_DIM")
        ,
          m.raisesAnything())
      )
      test("Position attribute not on input model - throws", ()->
        input.set(
          NOT_MOCK_POS:10
          MOCK_DIM:2
        )
        a(
          ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
        ,
          m.raisesAnything())
      )
      test("Dimension not set - throws", ()->
        input.set(
          MOCK_POS:10
          MOCK_DIM:2
        )
        a(
          ()->Formatters.centroid(input, "MOCK_POS")
        ,
          m.raisesAnything())
      )
      test("Dimension attribute not on input model - throws", ()->
        input.set(
          MOCK_POS:10
          NOT_MOCK_DIM:2
        )
        a(
          ()->Formatters.centroid(input, "MOCK_POS","MOCK_DIM")
        ,
          m.raisesAnything())
      )
    )
  )
)

