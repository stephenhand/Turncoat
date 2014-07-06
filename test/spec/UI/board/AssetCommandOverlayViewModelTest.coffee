require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/widgets/GameBoardViewModel","UI/board/AssetCommandOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          @setGameMock = JsMockito.mockFunction()
          @initializeMock = JsMockito.mockFunction()
          super()
        setGame:(game)->
          @setGameMock(game)
        initialize:()->
          @initializeMock()
      ret
    )
  )
)

define(["isolate!UI/board/AssetCommandOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone"], (AssetCommandOverlayViewModel, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/board/AssetCommandOverlayViewModel"]
  suite("AssetCommandOverlayViewModel", ()->
    suite("initialize", ()->
      test("calls GameBoardViewModel initialize", ()->
        acovm = new AssetCommandOverlayViewModel()
        jm.verify(acovm.initializeMock)()
      )
      test("sets nominatedAssets as empty collection", ()->
        a(new AssetCommandOverlayViewModel().get("nominatedAssets"), m.allOf(m.instanceOf(Backbone.Collection), m.hasMember("models", m.empty())))
      )
    )
    suite("setGame", ()->
      test("calls GameBoardViewModel setGame with game", ()->
        g = {}
        acovm = new AssetCommandOverlayViewModel()
        acovm.setGame(g)
        jm.verify(acovm.setGameMock)(g)
      )

      test("game set - sets getCommandsForAsset to function", ()->
        acovm = new AssetCommandOverlayViewModel()
        acovm.setGame({})
        a(acovm.getCommandsForAsset, m.func())
      )
      test("game not set - deletes getCommandsForAsset", ()->
        acovm = new AssetCommandOverlayViewModel()
        acovm.getCommandsForAsset = ()->
        acovm.setGame()
        a(acovm, m.not(m.hasMember('getCommandsForAsset')))
      )
    )
    suite("setAsset", ()->
      suite("has valid ships collection", ()->
        acovm = null
        setup(()->
          acovm = new AssetCommandOverlayViewModel()
          acovm.set("ships",
            new Backbone.Collection([
              modelId:"MODEL 1"
            ,
              modelId:"MODEL 2"
            ,
              modelId:"MODEL 3"
            ])
          )
        )
        suite("called with id matching modeld of ship in collection", ()->
          test("Game not set - throws", ()->
            a(()->
              acovm.setAsset("MODEL 2")
            , m.raisesAnything())
          )
          suite("Game set", ()->
            g = null
            act = null
            setup(()->
              act = new Backbone.Collection([
                new Backbone.Model(
                  name:"ACTION 1"
                )
              ])
              acovm.setGame(
                g =
                  getCurrentControllingPlayer:()->
                    new Backbone.Model(
                      fleet:new Backbone.Collection([
                        new Backbone.Model(
                          id:"MODEL 2"
                          actions: act
                        )
                      ])
                    )
              )
            )
            test("any part of property chain game.getCurrentControllingPlayer().get('fleet').get(id).get('actions').at(0) missing - throws", ()->
              act.reset()
              a(()->
                acovm.setAsset("MODEL 2")
              , m.raisesAnything())
            )

            test("adds ship to nominated assets collection", ()->
              acovm.setAsset("MODEL 2")
              a(acovm.get("nominatedAssets").models, m.equivalentArray([acovm.get("ships").at(1)]))
            )
            test("removes anything already nominated assets collection", ()->
              acovm.set("nominatedAssets", new Backbone.Collection([
                "OTHER"
              ,
                "STUFF"
              ]))
              acovm.setAsset("MODEL 2")
              a(acovm.get("nominatedAssets").models, m.equivalentArray([acovm.get("ships").at(1)]))
            )
            suite("Valid game, model ship, viewmodel ship and actions", ()->
              setup(()->
              )
              test("Single action that has no types - adds a command with label same as action name and viewModel ship as target for first command", ()->
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), "ACTION 1")
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
              )
              test("Single action that has no types and no name - adds a command with no name", ()->
                act.at(0).unset("name")
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), m.nil())
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
              )
              test("Multiple actions, first has no types - adds a command as first action", ()->
                act.push(new Backbone.Model(
                  name:"SOMETHING"
                  types:new Backbone.Collection([
                    new Backbone.Model(name:"ELSE")
                  ,
                    new Backbone.Model(name:"ENTIRELY")
                  ])
                ))
                act.push(new Backbone.Model(
                  name:"SOMETHING ELSE AGAIN"
                ))
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), "ACTION 1")
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
              )
              test("Multiple actions, first has types - adds a command for each type", ()->
                act.at(0).set("types", new Backbone.Collection([
                  new Backbone.Model(name:"TYPE 1")
                ,
                  new Backbone.Model(name:"TYPE 2")
                ]))
                act.push(new Backbone.Model(
                  name:"SOMETHING ELSE AGAIN"
                ))
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), "TYPE 1")
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
                a(acovm.get("commands").at(1).get("label"), "TYPE 2")
                a(acovm.get("commands").at(1).get("target"), acovm.get("ships").at(1))
              )
              test("Multiple actions, first has type with missing name - adds a command no label", ()->
                act.at(0).set("types", new Backbone.Collection([
                  new Backbone.Model()
                ,
                  new Backbone.Model(name:"TYPE 2")
                ]))
                act.push(new Backbone.Model(
                  name:"SOMETHING ELSE AGAIN"
                ))
                acovm.setAsset("MODEL 2")
                a(acovm.get("commands").at(0).get("label"), m.nil())
                a(acovm.get("commands").at(0).get("target"), acovm.get("ships").at(1))
                a(acovm.get("commands").at(1).get("label"), "TYPE 2")
                a(acovm.get("commands").at(1).get("target"), acovm.get("ships").at(1))
              )
              test("Always adds pass command to end of collection", ()->
                act.at(0).set("types", new Backbone.Collection([
                  new Backbone.Model(name:"TYPE 1")
                ,
                  new Backbone.Model(name:"TYPE 2")
                ]))
                act.push(new Backbone.Model(
                  name:"SOMETHING ELSE AGAIN"
                ))
                acovm.setAsset("MODEL 2")

                a(acovm.get("commands").at(2).get("label"), "Pass")
                a(acovm.get("commands").at(2).get("target"), acovm.get("ships").at(1))

              )
            )
          )
        )
        test("called with id not matching modelId in ships collection - throws", ()->
          a(()->
            acovm.setAsset("CHEESE")
          ,
            m.raisesAnything()
          )
        )
        test("called with nothing - empties nominatedAssets", ()->
          acovm.set("nominatedAssets", new Backbone.Collection([
            "OTHER"
          ,
            "STUFF"
          ]))
          acovm.setAsset()
          a(acovm.get("nominatedAssets"),m.hasMember("models", m.empty()))
        )
      )
      test("Has invalid ships collection - throws", ()->
        a(()->
          acovm.set("ships",[])
          acovm.setAsset("CHEESE")
        ,
          m.raisesAnything()
        )
      )
      test("Has no ships collection - throws", ()->
        a(()->
          acovm.unset("ships")
          acovm.setAsset("CHEESE")
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

