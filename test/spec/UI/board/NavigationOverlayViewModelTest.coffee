require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NominatedAssetOverlayViewModel","UI/board/NavigationOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          super()
          @superSetGame = JsMockito.mockFunction()
          @superSetAsset = JsMockito.mockFunction()
        setGame:(game)->
          @superSetGame(game)
        setAsset:(ass)->
          @superSetAsset(ass)
        getAsset:()->
        initialize:()->
      ret
    )
  )
)

define(["isolate!UI/board/NavigationOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "backbone"],
(NavigationOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/NavigationOverlayViewModel"]
  suite("NavigationOverlayViewModel", ()->
    suite("setGame", ()->
      game = null
      ghost = null
      setup(()->
        ghost = {}
        game =
          ghost:jm.mockFunction()
        jm.when(game.ghost)().then(()->ghost)
      )
      test("calls parent implementation with ghost of game provided", ()->
        novm = new NavigationOverlayViewModel()
        novm.setGame(game)
        jm.verify(game.ghost)()
        jm.verify(novm.superSetGame)(ghost)
      )
    )
    suite("setAsset", ()->
      novm = null
      model = {}
      setup(()->
        novm = new NavigationOverlayViewModel()
      )
      test("calls parent implementation with input", ()->
        novm.setAsset(model)
        jm.verify(novm.superSetAsset)(model)
      )
      test("creates planned actions collection", ()->
        a(novm.get("plannedActions"), m.nil())
        novm.setAsset(model)
        a(novm.get("plannedActions"), m.instanceOf(Backbone.Collection))
      )
    )
    suite("setAction", ()->
      novm = null
      model = {}
      setup(()->
        novm = new NavigationOverlayViewModel()
      )
      test("sets moveType with the name of the command model provided", ()->
        novm.setAction(new Backbone.Model(
          name:"AN ACTION"
        ))
        a(novm.get("moveType"),"AN ACTION")
      )
      test("model has no action name - sets no move type", ()->
        novm.setAction(new Backbone.Model())
        a(novm.get("moveType"),m.nil())
      )
      test("input is not model - throws", ()->
        a(()->
          novm.setAction({})
        ,
          m.raisesAnything()
        )
      )
      test("no input - throws", ()->
        a(()->
          novm.setAction()
        ,
          m.raisesAnything()
        )
      )
    )
    suite("updatePreview", ()->
      novm = null
      nominated = null
      setup(()->
        novm = new NavigationOverlayViewModel()
        nominated = new Backbone.Model()
        nominated.calculateClosestMoveAction = jm.mockFunction()
        novm.getAsset = jm.mockFunction()
        jm.when(novm.getAsset)().then(()->nominated)
        novm.set("moveType", "MOCK MOVE TYPE")
      )
      test("Calls calculateClosestMoveAction on move rule with nominatedAsset, with moveType and coordinates", ()->
        novm.updatePreview(1337, 666)
        jm.verify(nominated.calculateClosestMoveAction)("MOCK MOVE TYPE", 1337, 666)
      )
      test("no move type - throws", ()->
        novm.unset("moveType")
        jm.when(novm.getAsset)().then(()->)
        a(()->
          novm.updatePreview(1337, 666)
        ,
          m.raisesAnything()
        )
      )
      test("no nominated asset - throws", ()->
        jm.when(novm.getAsset)().then(()->)
        a(()->
            novm.updatePreview(1337, 666)
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

