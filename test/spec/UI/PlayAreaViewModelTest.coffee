updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      ret=Backbone.Model.extend(
        initialize:()->
          @set("overlays", new Backbone.Collection())
          @set("MOCK LAYER", new Backbone.Collection())
        setGame:()->
      )
      ret
    )
  )
  Isolate.mapAsFactory("AppState","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      new Backbone.Model(
        currentUser:new Backbone.Model(id:"MOCK_CURRENT_USER")
      )
    )
  )
)

define(["isolate!UI/PlayAreaViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers","backbone" ], (PlayAreaViewModel, m, o, a, jm, v, Backbone)->
  suite("PlayAreaViewModel", ()->
    ASSETSELECTIONVIEW = "assetSelectionView"
    ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"
    ASSETCOMMANDVIEW = "assetCommandView"

    mocks = mockLibrary["UI/PlayAreaViewModel"]

    suite("initialise", ()->
      origGet = null
      overlays = null
      setup(()->
        overlays = new Backbone.Collection()
        underlays = new Backbone.Collection()
        origGet = mocks["UI/widgets/GameBoardViewModel"].prototype.get
        mocks["UI/widgets/GameBoardViewModel"].prototype.get = (att)->
          if att is "overlays" then overlays
          if att is "underlays" then underlays
      )
      teardown(()->
        mocks["UI/widgets/GameBoardViewModel"].prototype.get = origGet
      )
      test("Creates new gameboard widget as 'gameBoard' attribute", ()->
        pavm = new PlayAreaViewModel()
        a(pavm.get("gameBoard"), m.instanceOf(mocks["UI/widgets/GameBoardViewModel"]))
      )
    )
    suite("setViewAPI", ()->
      test("Called with parameter with requestOverlay method - does not throw", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI(
              requestOverlay:()->
            )
        ,
          m.not(m.raisesAnything())
        )
      )
      test("Called with parameter with non callable requerstOverlay property - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI(
              requestOverlay:{}
            )
        ,
          m.raisesAnything()
        )
      )
      test("Called with parameter without requestOverlay property - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI({})
        ,
          m.raisesAnything()
        )
      )
      test("Called without parameter - throws", ()->
        pavm = new PlayAreaViewModel()
        a(
          ()->
            pavm.setViewAPI()
        ,
          m.raisesAnything()
        )
      )
    )
    suite("setGame", ()->
      g = null
      pavm = null
      mockUnderlayModel = null
      setup(()->

        mockUnderlayModel =
          on:jm.mockFunction()
          get:jm.mockFunction()
        g =
          getCurrentControllingUser:jm.mockFunction()
        jm.when(g.getCurrentControllingUser)().then(()->
          new Backbone.Model(id:"MOCK_CURRENT_USER")
        )
        pavm = new PlayAreaViewModel()
        pavm.get("gameBoard").setGame = jm.mockFunction()
        getter = jm.mockFunction()
        pavm.get("gameBoard").set("overlays",add:jm.mockFunction())
        pavm.get("gameBoard").set("underlays",
          add:jm.mockFunction()
          get:getter
        )
        jm.when(getter)(ASSETSELECTIONVIEW).then((vw)->
          get:(x)->
             if x is "overlayModel" then mockUnderlayModel
        );
      )
      test("Called with game - calls setGame on gameboard with game", ()->
        pavm.setGame(g)
        jm.verify(pavm.get("gameBoard").setGame)(g)
      )
      suite("Current player is controlling player", ()->
        test("Adds model to underlays with ASSETSELECTIONVIEW as id", ()->
          pavm.setGame(g)
          jm.verify(pavm.get("gameBoard").get("underlays").add)(m.hasMember("id", ASSETSELECTIONVIEW))
        )
        test("Adds model to overlays with ASSETSELECTIONHOTSPOTS as id", ()->
          pavm.setGame(g)
          jm.verify(pavm.get("gameBoard").get("overlays").add)(m.hasMember("id", ASSETSELECTIONHOTSPOTS))
        )
        test("Activating underlay fails to create desired layer structure - throws", ()->
          getter = jm.mockFunction()
          pavm.get("gameBoard").set("underlays",
            add:jm.mockFunction()
            get:getter
          )
          jm.when(getter)(ASSETSELECTIONVIEW).then((vw)->
            get:(x)->
          );
          a(()->
            pavm.setGame(g)
          ,m.raisesAnything())
        )
        suite("View API is set", ()->
          api = null
          setup(()->
            api =
              requestOverlay:jm.mockFunction()
            pavm.setViewAPI(api)

          )
          test("Calls requestOverlay with game, ASSETSELECTIONVIEW as id and underlays as layer", ()->
            pavm.setGame(g)
            jm.verify(api.requestOverlay)(
              m.allOf(
                m.hasMember("id", ASSETSELECTIONVIEW),
                m.hasMember("gameData", g),
                m.hasMember("layer", "underlays")
              )
            )
          )
          test("Calls requestOverlay with game, ASSETSELECTIONHOTSPOTS as id, overlays as layer and overlayModel just added to underlays as model", ()->
            pavm.setGame(g)
            jm.verify(api.requestOverlay)(
              m.allOf(
                m.hasMember("id", ASSETSELECTIONHOTSPOTS),
                m.hasMember("gameData", g),
                m.hasMember("layer", "overlays")   ,
                m.hasMember("overlayModel", mockUnderlayModel)
              )
            )
          )
          test("Listens to the overlay/underlay model for changes to nominatedAsset", ()->
            pavm.setGame(g)
            jm.verify(mockUnderlayModel.on)("change:nominatedAsset", m.func(), pavm)
          )
          suite("overlay/underlay change:nominatedAsset listener",()->
            listener = null
            nominated = null
            commandOverlay = null
            getter = null
            setup(()->
              getter = jm.mockFunction()
              commandOverlay =
                setAsset : jm.mockFunction()
                on : jm.mockFunction()
              pavm.get("gameBoard").set("overlays",
                add:jm.mockFunction()
                get:getter
              )
              jm.when(getter)(ASSETCOMMANDVIEW).then((vw)->
                get:(x)->
                  if x is "overlayModel" then commandOverlay
              )
              nominated = {}
              jm.when(mockUnderlayModel.get)("nominatedAsset").then(()->nominated)
              jm.when(mockUnderlayModel.on)("change:nominatedAsset", m.func(), pavm).then((e,l,c)->
                listener=l
              )
              pavm.setGame(g)
              pavm.activateOverlay = jm.mockFunction()
            )
            test("Activates command overlay with nominatedAsset",()->
              listener.call(pavm, {},
                get:(key)->
                  if key is "modelId" then "MOCK ASSET ID"
              )
              jm.verify(pavm.activateOverlay)(ASSETCOMMANDVIEW,"overlays")
            )
            test("Sets asset on command overlay using id from model passed in from listener",()->
              listener.call(pavm, {},
                get:(key)->
                  if key is "modelId" then "MOCK ASSET ID"
              )
              jm.verify(commandOverlay.setAsset)("MOCK ASSET ID")
            )
            test("Command overlay model not where expected - throws",()->
              jm.when(getter)(ASSETCOMMANDVIEW).then((vw)->
                get:(x)->
              )
              a(()->
                listener.call(pavm, {},
                  get:(key)->
                    if key is "modelId" then "MOCK ASSET ID"
                )
              ,
                m.raisesAnything()
              )
            )
            test("Nominated asset has no model id - sets asset with nothing",()->

              listener.call(pavm, {},
                get:(key)->
              )
              jm.verify(commandOverlay.setAsset)(m.nil())
            )
            test("Listens to the overlay/underlay model for changes to selectedCommand", ()->
              listener.call(pavm, {},
                get:(key)->
              )
              jm.verify(commandOverlay.on)("change:selectedCommand", m.func(), pavm)
            )
            suite("selectedCommand change listener", ()->
              selectedCommandListener = null
              aovm = null
              command = null
              setup(()->
                jm.when(commandOverlay.on)("change:selectedCommand", m.func(), pavm).then((ev, l, m)->
                  selectedCommandListener = l
                )
                listener.call(pavm, {},
                  get:(key)->
                )
                command =
                  get:(key)->
                    switch key
                      when "overlay" then "MOCK ACTION OVERLAY"
                      when "target" then new Backbone.Model(modelId:"MOCK SHIP ID")
                aovm =
                  setAsset : jm.mockFunction()
                  setAction: jm.mockFunction()
                jm.when(getter)("MOCK ACTION OVERLAY").then((vw)->
                  get:(x)->
                    if x is "overlayModel" then aovm
                )
              )
              test("Command not specified - throws", ()->

                a(()->
                  selectedCommandListener.call(pavm, {})
                , m.raisesAnything()
                )
              )
              test("Overlay not specified - does nothing",()->
                selectedCommandListener.call(pavm, {}, get:()->)
                jm.verify(pavm.activateOverlay, v.never())("MOCK ACTION OVERLAY", m.anything())
                jm.verify(aovm.setAsset, v.never())(m.anything())
              )
              test("Activates action overlay using overlay name supplied on command",()->
                selectedCommandListener.call(pavm, {}, command)
                jm.verify(pavm.activateOverlay)("MOCK ACTION OVERLAY","overlays")
              )
              test("Activation adds overlay to collection correctly - setAsset is then called on overlay", ()->
                selectedCommandListener.call(pavm, {}, command)
                jm.verify(aovm.setAsset)("MOCK SHIP ID")
              )
              test("Activation adds overlay to collection correctly - setAction is then called on overlay with command", ()->
                selectedCommandListener.call(pavm, {}, command)
                jm.verify(aovm.setAction)(command)
              )
              test("Activation fails to add overlay to collection correctly - throws", ()->
                jm.when(getter)("MOCK ACTION OVERLAY").then((vw)->
                  get:(x)->
                )
                a(()->
                  selectedCommandListener.call(pavm, {}, command)
                , m.raisesAnything()
                )
              )
            )
          )
        )
      )
      test("Current player is not controlling player - adds and requests no overlays", ()->
        api =
          requestOverlay:jm.mockFunction()
        jm.when(g.getCurrentControllingUser)().then(()->
          new Backbone.Model(id:"NOT MOCK_CURRENT_USER")
        )
        pavm.setViewAPI(api)
        pavm.setGame(g)
        jm.verify(api.requestOverlay, v.never())(
          m.anything()
        )
        jm.verify(pavm.get("gameBoard").get("underlays").add, v.never())(m.anything())
        jm.verify(pavm.get("gameBoard").get("overlays").add, v.never())(m.anything())
      )
      test("Called without game - calls setGame on gameboard with undefined", ()->
        pavm.setGame()
        jm.verify(pavm.get("gameBoard").setGame)(m.nil())
      )
    )
    suite("activateOverlay", ()->
      pavm = null
      setup(()->
        pavm = new PlayAreaViewModel()
      )
      test("Called without game - does nothing", ()->
        pavm.activateOverlay("AN ID")
        a(pavm.get("gameBoard").get("overlays").length, 0)
        pavm.setGame(
          getCurrentControllingUser:()->
            get:()->
        )
        pavm.setGame()
        pavm.activateOverlay("AN ID")
        a(pavm.get("gameBoard").get("overlays").length, 0)

      )
      suite("Called when game set", ()->
        api=null
        g=
          getCurrentControllingUser:()->
            get:()->
        setup(()->
          api =
            requestOverlay:jm.mockFunction()
          pavm.setViewAPI(api)
          pavm.setGame(g)
        )
        test("Creates a model in overlays with specified id on collection at attribute specified by layer", ()->
          pavm.activateOverlay("AN ID","MOCK LAYER")
          a(pavm.get("gameBoard").get("MOCK LAYER").length, 1)
          a(pavm.get("gameBoard").get("MOCK LAYER").at(0).get("id"), "AN ID")
        )
        test("calls requestOverlay on the current view api with id and game model", ()->
          pavm.trigger = jm.mockFunction()
          pavm.activateOverlay("AN ID", "MOCK LAYER")
          jm.verify(api.requestOverlay)(m.allOf(
            m.hasMember("id","AN ID"),
            m.hasMember("gameData",g)
          ))
        )
        test("Layer attribute not set - throws error", ()->
          pavm.get("gameBoard").unset("MOCK LAYER")
          a(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          ,
            m.raisesAnything()
          )
        )
        test("Layer attribute not valid bb collection - throws", ()->
          pavm.get("gameBoard").set("MOCK LAYER", {})
          a(()->
            pavm.activateOverlay("AN ID","MOCK LAYER")
          ,
            m.raisesAnything()
          )
        )
        test("Model specified - passes this to request as overlayModel property", ()->
          om = {}
          pavm.trigger = jm.mockFunction()
          pavm.activateOverlay("AN ID", "MOCK LAYER",om)
          jm.verify(api.requestOverlay)(m.hasMember("overlayModel",om))
        )
      )
    )
  )


)

