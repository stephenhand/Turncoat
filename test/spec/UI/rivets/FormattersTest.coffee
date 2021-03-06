require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rivets","UI/rivets/Formatters", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        binders:{}
        formatters:{}
        config:
          rootInterface:'*'
        adapters:
          '*':
            read:JsMockito.mockFunction()
          '.':
            read:JsMockito.mockFunction()
          ':':
            read:JsMockito.mockFunction()

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
        jm.when(mocks["sprintf"].func)(m.anything(),m.anything()).then(
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
        asteriskAdapterResult = null
        dotAdapterResult = null
        colonAdapterResult = null
        model = null
        setup(()->
          asteriskAdapterResult =
            propA:12
            propB:-16
            propC:20.5
          dotAdapterResult =
            propA:112
            propB:-116
            propC:120.5
          colonAdapterResult =
            propA:212
            propB:-216
            propC:220.5
          model =
            propA:12
            propB:-16
            propC:20.5
          jm.when(mocks["rivets"].adapters["*"].read)(m.anything(), m.anything()).then((m, path)->asteriskAdapterResult[path])
          jm.when(mocks["rivets"].adapters["."].read)(m.anything(), m.anything()).then((m, path)->dotAdapterResult[path])
          jm.when(mocks["rivets"].adapters[":"].read)(m.anything(), m.anything()).then((m, path)->colonAdapterResult[path])

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
        test("Calls rivets adapter read method using input and attribute name using rootInterface adapter if none specified", ()->
          Formatters.calc(model, "Math.floor(%d*3)", "propA")
          jm.verify(mocks["rivets"].adapters["*"].read)(model,"propA")
        )
        test("Calls rivets adapter read method using input and attribute name using appropriate adapter if specified", ()->
          Formatters.calc(model, "Math.floor(%d*3)", ":propA")
          jm.verify(mocks["rivets"].adapters[":"].read)(model,"propA")
        )
        test("Chains rivets adapter read calls using each value in next adapter if chain specified", ()->
          Formatters.calc(model, "Math.floor(%d*3)", ":propA.propB*propA.propC")
          jm.verify(mocks["rivets"].adapters[":"].read)(model,"propA")
          jm.verify(mocks["rivets"].adapters["."].read)(212,"propB")
          jm.verify(mocks["rivets"].adapters["*"].read)(-116,"propA")
          jm.verify(mocks["rivets"].adapters["."].read)(12,"propC")
        )
        test("Keypath chains can still omit start adapter at start and use default", ()->
          Formatters.calc(model, "Math.floor(%d*3)", "propA.propB*propC.propC")
          jm.verify(mocks["rivets"].adapters["*"].read)(model,"propA")
          jm.verify(mocks["rivets"].adapters["."].read)(12,"propB")
          jm.verify(mocks["rivets"].adapters["*"].read)(-116,"propC")
          jm.verify(mocks["rivets"].adapters["."].read)(20.5,"propC")
        )
        test("Single attribute specified, single substitution specified in mask - calculates using value as read by rivets adapter of input using attribute name", ()->
          a(Formatters.calc(model, "Math.floor(%d*3)", "propA"),36)
        )
        test("Uses last value in keypath chain for substitution", ()->
          a(Formatters.calc(model, "Math.floor(%f*3)", "propA.propB*propA.propC"),361)
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
          asteriskAdapterResult.propB="THREE"
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA")
          ,
            m.raisesAnything()
          )
        )
        test("Any attributes are missing - throws", ()->
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "notPropB", "propA")
          ,
            m.raisesAnything()
          )
        )
        test("Any unused attributes are missing or non numeric - throws", ()->
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA", "notPropB")
          ,
            m.raisesAnything()
          )
          asteriskAdapterResult.propC="THREE"
          a(()->
            Formatters.calc(model, "%d+Math.sqrt(%d*3)", "propB", "propA", "propC")
          ,m.raisesAnything())
        )
        test("Rivets adapter throws - throws", ()->
          JsMockito.when(mocks["rivets"].adapters["*"].read)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((obj, key)->
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
    suite("pathDefinitionFromActions", ()->
      setup(()->

      )
      suite("Single Action", ()->
        test("No events - returns non rendering placeholder",()->
          a(Formatters.pathDefinitionFromActions(
            events:new Backbone.Collection([])
          ), "m 0 0")
        )
        suite("Single changePosition event", ()->
          test("No waypoints in first event - returns non rendering placeholder",()->
            a(Formatters.pathDefinitionFromActions(
              events:new Backbone.Collection([
                rule:"ships.events.changePosition"
                waypoints:new Backbone.Collection([])
              ])
            ), "m 0 0")
          )
          suite("Has starting point", ()->
            action = null
            setup(()->
              action = new Backbone.Model(
                events:new Backbone.Collection([
                  rule:"ships.events.changePosition"
                  startingPoint:new Backbone.Model(
                    x:50
                    y:40
                    bearing:100
                  )
                  vector:new Backbone.Model(
                    x:-10
                    y:10
                    rotation:60
                  )
                  waypoints:new Backbone.Collection([])
                ])
              )

            )
            test("Moves to first waypoint and produces relative cubic Bezier curve finishing in event position",()->

              a(Formatters.pathDefinitionFromActions(action), m.matches(/^m 50 40 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} -10 10$/))
            )
            test("Adding waypoints doesn't affect path definition",()->

              oneWP = Formatters.pathDefinitionFromActions(action);
              action.get("events").at(0).get("waypoints").add(
                x:180
                y:-20
                bearing:135
              )
              a(oneWP, Formatters.pathDefinitionFromActions(action))
              action.get("events").at(0).get("waypoints").add(
                x:-1802
                y:2000
                bearing:-13
              )
              a(oneWP, Formatters.pathDefinitionFromActions(action))
            )
            test("Missing position - throws",()->
              action.get("events").at(0).unset("vector")
              a(()->
                Formatters.pathDefinitionFromActions(action)
              ,
                m.raisesAnything()
              )
            )
            test("Missing X position data - throws", ()->
              action.get("events").at(0).get("vector").unset("x")
              a(()->
                Formatters.pathDefinitionFromActions(action)
              ,
                m.raisesAnything()
              )
            )
            test("Missing Y position data - throws", ()->
              action.get("events").at(0).get("vector").unset("y")
              a(()->
                Formatters.pathDefinitionFromActions(action)
              ,
                m.raisesAnything()
              )
            )
            test("Missing bearing position data - throws", ()->
              action.get("events").at(0).get("vector").unset("rotation")
              a(()->
                Formatters.pathDefinitionFromActions(action)
              ,
                m.raisesAnything()
              )
            )
          )
        )
        test("Single event of other type - returns non rendering placeholder",()->
          a(Formatters.pathDefinitionFromActions(
            events:new Backbone.Collection([
              rule:"not changePosition"
              startingPoint:new Backbone.Model(
                x:50
                y:40
                bearing:100
              )
              vector:new Backbone.Model(
                x:0
                y:0
                rotation:60
              )
            ])
          ), "m 0 0")
        )
        suite("Multiple events", ()->
          action = null
          setup(()->
            action = new Backbone.Model(
              events:new Backbone.Collection([
                rule:"not changePosition"
                startingPoint:new Backbone.Model(
                  x:30
                  y:20
                  bearing:32
                )
                vector:new Backbone.Model(
                  x:20
                  y:30
                  rotation:48
                )
              ,
                rule:"ships.events.changePosition"
                startingPoint:new Backbone.Model(
                  x:50
                  y:40
                  bearing:100
                )
                vector:new Backbone.Model(
                  x:-10
                  y:10
                  rotation:60
                )
              ,
                rule:"not changePosition"
                vector:new Backbone.Model(
                  x:160
                  y:170
                  bearing:123
                )
              ,
                rule:"ships.events.changePosition"
                vector:new Backbone.Model(
                  x:20
                  y:20
                  rotation:-99
                )
              ,
                rule:"not changePosition"
                vector:new Backbone.Model(
                  x:61
                  y:71
                  rotation:2
                )
              ,
                rule:"ships.events.changePosition"
                vector:new Backbone.Model(
                  x:5
                  y:5
                  rotation:14
                )
              ])
            )
          )
          test("Generates first curve from first waypoint to position, then for each subsequent event add another curve ending in the next events position, ignoring any events not named changePosition", ()->

            a(Formatters.pathDefinitionFromActions(action), m.matches(/^m 50 40 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} -10 10 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 20 20 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 5 5$/))
          )
          test("Ignores waypoints in subsequent changePosition events completely", ()->

            noWPs = Formatters.pathDefinitionFromActions(action)
            action.get("events").at(3).set("waypoints", new Backbone.Collection([
              x:180
              y:-20
              bearing:135
            ]))
            a(noWPs, Formatters.pathDefinitionFromActions(action))
            action.get("events").at(5).set("waypoints", new Backbone.Collection([
              x:-1802
              y:2000
              bearing:-13
            ]))
            a(noWPs, Formatters.pathDefinitionFromActions(action))
          )
        )
      )
      suite("Multiple Actions", ()->
        actions = null
        setup(()->
          actions = new Backbone.Collection([
            events:new Backbone.Collection([
              rule:"not changePosition"
              startingPoint:new Backbone.Model(
                x:30
                y:20
                bearing:32
              )
              vector:new Backbone.Model(
                x:-10
                y:10
                rotation:16
              )
            ,
              rule:"ships.events.changePosition"
              startingPoint:new Backbone.Model(
                x:50
                y:40
                bearing:100
              )
              vector:new Backbone.Model(
                x:-10
                y:10
                rotation:60
              )
            ,
              rule:"not changePosition"
              vector:new Backbone.Model(
                x:160
                y:170
                rotation:123
              )
            ,
              rule:"ships.events.changePosition"
              vector:new Backbone.Model(
                x:20
                y:20
                rotation:-99
              )
            ,
              rule:"not changePosition"
              vector:new Backbone.Model(
                x:61
                y:71
                bearing:2
              )
            ,
              rule:"ships.events.changePosition"
              vector:new Backbone.Model(
                x:5
                y:5
                rotation:14
              )
            ])
          ,
            events:new Backbone.Collection([
              rule:"not changePosition"
              startingPoint:new Backbone.Model(
                x:30
                y:20
                bearing:32
              )
              vector:new Backbone.Model(
                x:125
                y:-125
                rotation:48
              )
            ])
          ,
            events:new Backbone.Collection([
              rule:"ships.events.changePosition"
              vector:new Backbone.Model(
                x:-45
                y:-45
                rotation:48
              )
            ])
          ,
            events:new Backbone.Collection([
              rule:"ships.events.changePosition"
              vector:new Backbone.Model(
                x:20
                y:20
                rotation:145
              )
            ,
              rule:"not changePosition"
              vector:new Backbone.Model(
                x:160
                y:170
                rotation:123
              )
            ,
              rule:"ships.events.changePosition"
              vector:new Backbone.Model(
                x:25
                y:25
                rotation:-144
              )
            ])
          ])
        )

        test("Generates first curve from waypoint to position of the first event of the first, then for each subsequent event in that action, and all events in all subsequent actions add another curve ending in the next events position, ignoring any events not named changePosition", ()->
          a(Formatters.pathDefinitionFromActions(actions), m.matches(/^m 50 40 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} -10 10 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 20 20 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 5 5 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} -45 -45 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 20 20 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 25 25$/))
        )
        test("Ignores first changePosition event's startingPoint in subsequent actions completely", ()->
          noWPs = Formatters.pathDefinitionFromActions(actions)
          actions.at(2).get("events").at(0).set("startingPoint", new Backbone.Model(
            x:180
            y:-20
            bearing:135
          ))
          a(noWPs, Formatters.pathDefinitionFromActions(actions))
          actions.at(3).get("events").at(0).set("startingPoint", new Backbone.Model(
            x:-1802
            y:2000
            bearing:-13
          ))
          a(noWPs, Formatters.pathDefinitionFromActions(actions))
        )
        test("Ignores actions with no events collection", ()->
          actions.at(2).unset("events")
          a(Formatters.pathDefinitionFromActions(actions), m.matches(/^m 50 40 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} -10 10 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 20 20 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 5 5 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 20 20 c(( -?[0-9]+(\.[0-9]+)?){2}\,){2} 25 25$/))
        )
      )
    )
  )
)

