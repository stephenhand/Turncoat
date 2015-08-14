require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState", 'UI/FleetAsset2DViewModel', (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      on:JsMockito.mockFunction()
      get:(key)->
        if key is 'game'
          state:
            searchGameStateModels:(func)->
              if func(
                id:"MOCKMODEL_UUID"
              )
                mockModel =
                  id:"MOCKMODEL_UUID"
                  get:JsMockito.mockFunction()
                  on:JsMockito.mockFunction()

                mockPos =
                  get:JsMockito.mockFunction()
                  on:JsMockito.mockFunction()

                JsMockito.when(mockModel.get)(m.anything()).then(
                  (att)->
                    switch att
                      when "position"
                        mockPos
                )

                JsMockito.when(mockPos.get)(m.anything()).then(
                  (att)->
                    switch att
                      when "x"
                        123
                      when "y"
                        321
                      when "bearing"
                        45

                )
                [mockModel]
    )
  )
)
define(["isolate!UI/FleetAsset2DViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (FleetAsset2DViewModel, m, o, a, jm, v)->
  mocks=window.mockLibrary["UI/FleetAsset2DViewModel"]
  mockModel =
    id:"MOCKMODEL_UUID"
    get:jm.mockFunction()
    on:jm.mockFunction()

  mockPos =
    get:jm.mockFunction()
    on:jm.mockFunction()
  mockDim =
    get:jm.mockFunction()
    on:jm.mockFunction()


  jm.when(mockModel.get)(m.anything()).then(
    (att)->
      switch att
        when "position"
          mockPos
        when "dimensions"
          mockDim
  )

  jm.when(mockPos.get)(m.anything()).then(
    (att)->
      switch att
        when "x"
          123
        when "y"
          321
        when "bearing"
          45
  )
  jm.when(mockDim.get)(m.anything()).then(
    (att)->
      switch att
        when "length"
          1337
        when "width"
          666
  )
  suite("FleetAsset2DViewModel", ()->

    suite("constructor", ()->

      origWatch = FleetAsset2DViewModel.prototype.watch
      setup(()->
        FleetAsset2DViewModel.prototype.watch = jm.mockFunction()
      )
      test("watches model", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        jm.verify(fa2dvm.watch)(m.hasItem(m.equivalentMap(
          model:mockModel
          attributes:[
            "position"
          ]
        )))
      )
      test("Watches model position", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        jm.verify(fa2dvm.watch)(m.hasItem(m.equivalentMap(
          model:mockModel.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        )))
      )
      test("Sets ClassList", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
      test("Sets XPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("xpx"),"123")
      )
      test("Sets YPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("ypx"),"321")
      )
      test("Sets length", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("length"),"1337")
      )
      test("Sets width", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("width"),"666")
      )
      test("Sets transform", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("transformDegrees"),"45")
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
    suite("updateFromFleetAsset", ()->

      mockOtherModel =
        id:"MOCKMODEL_UUID2"
        get:()->
          get:()->
        on:()->
      test("Sets XPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("xpx"),"123")
      )
      test("Sets YPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("ypx"),"321")
      )
      test("Sets transform", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("transformDegrees"),"45")
      )
      test("Different model id - does not update model id", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        fa2dvm.onModelUpdated(mockOtherModel)
        a(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
      test("Sets calculateClosestMoveAction method.", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.calculateClosestMoveAction, m.func())
      )
      suite("calculateClosestMoveAction", ()->
        mockRuleBook = null
        mockRuleEntry = null
        mockRule = null
        fa2dvm = null
        model = null
        modelRoot = null
        modelRootGhost = null
        modelGhost = null
        setup(()->
          mockRule =
            calculateManeuverRequired:jm.mockFunction()
            resolveAction:jm.mockFunction()
            calculateStraightLineMoveRequired:jm.mockFunction()
          mockRuleBook =
            lookUp:jm.mockFunction()

          mockRuleEntry =
            getActionRules:jm.mockFunction()
          jm.when(mockRuleBook.lookUp)("ships.actions.move").then((path)->
            mockRuleEntry
          )
          jm.when(mockRuleEntry.getActionRules)().then(()->
            mockRule
          )
          model = new Backbone.Model(
            position:new Backbone.Model()
            dimensions:new Backbone.Model()
            actions:new Backbone.Collection([
              new Backbone.Model(
                name:"move"

              )
            ])
          )
          model.set("position", new Backbone.Model(
            x:123
            y:321
            bearing:45
          ))
          modelGhost = new Backbone.Model(
            position:new Backbone.Model()
            dimensions:new Backbone.Model()
            actions:new Backbone.Collection([
              new Backbone.Model(
                name:"move"

              )
            ])
          )
          modelGhost.set("position", new Backbone.Model(
            x:123
            y:321
            bearing:45
          ))
          modelRootGhost =
            getRuleBook:()->
              mockRuleBook
            searchGameStateModels:jm.mockFunction()
            activate:jm.mockFunction()
          jm.when(modelRootGhost.searchGameStateModels)(m.anything()).then(
            ()->
              [modelGhost]
          )
          modelRoot=
            ghost:jm.mockFunction()
          jm.when(modelRoot.ghost)().then(
            ()->
              modelRootGhost
          )
          model.getRoot=()->
            modelRoot
          fa2dvm = new FleetAsset2DViewModel(null, model:model)

        )
        suite("Model has move action type defined.", ()->
          moveType = null
          maneuver = null
          setup(()->
            maneuver = new Backbone.Model()
            moveType = new Backbone.Model(
              name:"MOCK MOVE TYPE"
              maneuvers:new Backbone.Collection([
                new Backbone.Model()
              ])
            )
            model.get("actions").at(0).set("types", new Backbone.Collection([
              moveType
            ]))
          )
          test("Ghosts current game", ()->
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, 1, ()->)
            jm.verify(modelRoot.ghost)()
          )
          test("Looks up move rules in rulebook",()->
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, 1, ()->)
            jm.verify(mockRuleBook.lookUp)("ships.actions.move")
          )
          test("Gets rule from entry providing current game (retrieved from ship model)",()->
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, 1, ()->)
            jm.verify(mockRuleEntry.getActionRules)(modelRootGhost)
          )
          test("Activates ghost game with placeholder data",()->
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, 1, ()->)
            jm.verify(modelRootGhost.activate)(m.string(),m.hasMember("transportKey", m.string()))
          )
          suite("moveType has minDirection and maxDirection set", ()->
            setup(()->
              moveType.get("maneuvers").reset([maneuver])
              moveType.set("minDirection", 30)
              moveType.set("maxDirection", 60)
            )
            suite("called with margin", ()->
              test("coordinates supplied are within min/max direction range - calls calculateStraightline move with ghost ship, moveType selected and coordinates", ()->

                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 130, 321.5)
              )
              test("coordinates supplied are clockwise of min/max direction range but not by more degrees than specified margin - calls calculateStraightline move with ghost ship, moveType selected and coordinates", ()->

                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 125, 323, 35, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 125, 323)
              )
              test("coordinates supplied are anticlockwise of min/max direction range but not by more degrees than specified margin - calls calculateStraightline move with ghost ship, moveType selected and coordinates", ()->

                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 125, 319, 35, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 125, 319)
              )
              test("coordinates supplied are outside direction range and margin - calls calculateStraightline move with ghost ship, moveType selected and coordinates", ()->

                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 120, 319, 35, ()->)
                jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 120, 319)
              )
              test("logic unaffected by min/max direction range crossing over zero", ()->
                moveType.set("minDirection", 345)
                moveType.set("maxDirection", 15)
                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 314.5, 20, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 130, 314.5)
                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 123, 319, 35, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 123, 319)
                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 120, 325, 35, ()->)
                jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 120, 325)
              )
              test("logic unaffected by min/max direction range crossing over zero absolute bearing on ghost ships current bearing", ()->

                moveType.set("minDirection", 345)
                moveType.set("maxDirection", 15)
                model.get("position").attributes.bearing=0

                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 123, 314.5, 20, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 123, 314.5)
                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 121, 319, 35, ()->)
                jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 121, 319)
                fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 122, 330, 35, ()->)
                jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 122, 330)
              )
            )
            test("Called without margin - margin assumed to be zero", ()->
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, undefined ,()->)
              jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 130, 321.5)
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 125, 323, undefined ,()->)
              jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 125, 323)
            )
          )
          test("minDirection not set - assumed to be zero", ()->
            model.get("position").attributes.bearing=110
            moveType.get("maneuvers").reset([maneuver])
            moveType.unset("minDirection")
            moveType.set("maxDirection", 60)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321, 20.5, ()->)
            jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost, "MOCK MOVE TYPE", 130, 321)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 320.5, 20, ()->)
            jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 130, 320.5)
          )
          test("maxDirection not set - assumed to be zero", ()->
            model.get("position").attributes.bearing=70
            moveType.get("maneuvers").reset([maneuver])
            moveType.set("minDirection", 300)
            moveType.unset("maxDirection")
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321, 20.5, ()->)
            jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 130, 321)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, ()->)
            jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 130, 321.5)
          )
          test("min and max direction not set - assumed that only permitted straightline bearing is zero", ()->
            model.get("position").attributes.bearing=45
            moveType.get("maneuvers").reset([maneuver])
            moveType.unset("minDirection")
            moveType.unset("maxDirection")
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 320.5, 45, ()->)
            jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 130, 320.5)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 45, ()->)
            jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 130, 321.5)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 123.5, 310, 45, ()->)
            jm.verify(mockRule.calculateStraightLineMoveRequired)(modelGhost,"MOCK MOVE TYPE", 123.5, 310)
            fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 122.5, 310, 45, ()->)
            jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 122.5, 310)
          )
          test("OnComplete callback not set - throws", ()->
            a(()->
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, 1)
            ,
              m.raisesAnything()
            )
          )

          suite("Is using straightline move", ()->
            onComplete = null
            setup(()->
              moveType.set("minDirection", 30)
              moveType.set("maxDirection", 60)
            )
            test("calculateStraightLineMoveRequired returns nothing - calls onComplete with empty", ()->
              onComplete = jm.mockFunction()
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->)
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, onComplete)
              jm.verify(onComplete)(m.empty())
            )
            test("calculateStraightLineMoveRequired returns nothing - doesnt attempt to resolve any action", ()->
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->)
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, ()->)
              jm.verify(mockRule.resolveAction, v.never())(m.anything(), m.anything())
            )
            test("calculateStraightLineMoveRequired returns action - resolves action without resolving non deterministic events", ()->
              action = {}
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                action
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, ()->)
              jm.verify(mockRule.resolveAction)(action, false)
            )
            test("calculateStraightLineMoveRequired returns object with action property - does not call onComplete yet.", ()->
              onComplete = jm.mockFunction()
              res=null
              jm.when(onComplete)(m.anything()).then((r)->
                res=r
              )
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                "MOCK ACTION"
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, onComplete)
              jm.verify(onComplete, v.never())(m.anything())
            )
            test("calculateStraightLineMoveRequired returns object with action property then ghostModelPosition changes - calls calculateStraightLineMoveRequired again.", ()->
              onComplete = jm.mockFunction()
              res=null
              jm.when(onComplete)(m.anything()).then((r)->
                res=r
              )
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                "MOCK ACTION"
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, onComplete)
              modelGhost.get("position").set("x", 100)
              jm.verify(mockRule.calculateStraightLineMoveRequired, v.times(2))(m.anything(),m.anything(),m.anything(),m.anything())
            )
            test("calculateStraightLineMoveRequired returns object with action property then ghostModelPosition changes, this time no action returned - calls onComplete with that action", ()->
              onComplete = jm.mockFunction()
              res=null
              jm.when(onComplete)(m.anything()).then((r)->
                res=r
              )
              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                "MOCK ACTION"
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 130, 321.5, 20, onComplete)

              jm.when(mockRule.calculateStraightLineMoveRequired)(m.anything(),m.anything(),m.anything(),m.anything()).then(()->)
              modelGhost.get("position").set("x", 100)
              jm.verify(onComplete)(m.anything())
              a(res.length, 1)
              a(res[0], "MOCK ACTION")
            )
          )
          suite("Is using maneuver and model has single maneuver defined", ()->
            maneuver = null
            setup(()->
              maneuver = new Backbone.Model()
              moveType.get("maneuvers").reset([maneuver])
            )
            test("Queries rulebook's calculateManeuverRequired method with ghost ship, moveType selected, maneuver and coordinates",()->
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, undefined, ()->)
              jm.verify(mockRule.calculateManeuverRequired)(modelGhost,"MOCK MOVE TYPE", maneuver, 1337, 666)
            )
            test("calculateManeuverRequired returns nothing - returns empty", ()->
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->)
              a(fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666), m.empty())
            )
            test("calculateManeuverRequired returns no action - returns empty", ()->
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                {}
              )
              a(fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666), m.empty())
            )
            test("calculateManeuverRequired returns no action - doesn't resolve action", ()->
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                {}
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, undefined, ()->)
              jm.verify(mockRule.resolveAction, v.never())(m.anything(), m.anything())
            )
            test("calculateManeuverRequired returns action - resolves action without resolving non deterministic events", ()->
              action = {}
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                action:action
              )
              fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666, ()->)
              jm.verify(mockRule.resolveAction)(action, false)
            )
            test("Returns action with no shortfall - returns single action", ()->
              action = {}
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                action:action
              )
              a(fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666), m.equivalentArray([action]))
            )
            test("Returns action with shortfall - still returns single action", ()->
              action = {}
              jm.when(mockRule.calculateManeuverRequired)(m.anything(),m.anything(),m.anything(),m.anything(),m.anything()).then(()->
                action:action
                shortfall:20
              )
              a(fa2dvm.calculateClosestMoveAction("MOCK MOVE TYPE", 1337, 666), m.equivalentArray([action]))
            )
          )
        )
      )
    )
  )
)

