require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/TypeRegistry", "rules/AssetPermittedActions", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class mat1 extends Backbone.Model
      class mat2 extends Backbone.Model
      class mat3 extends Backbone.Model

      m=
        MOCK_ACTION_TYPE1:mat1
        MOCK_ACTION_TYPE2:mat2
        MOCK_ACTION_TYPE3:mat3
      m
    )
  )
)

define(["isolate!rules/AssetPermittedActions", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "backbone"],
(AssetPermittedActions, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["rules/AssetPermittedActions"]

  suite("AssetPermittedActions", ()->
    suite("getPermittedActionsForAsset", ()->
      game = null
      ruleBook = null
      ruleEntry = null
      setup(()->
        game = new Backbone.Model()
        ruleEntry =
          getRule:jm.mockFunction()
        ruleBook =
          lookUp:jm.mockFunction()
        game.getRuleBook = ()->
          ruleBook
        jm.when(ruleBook.lookUp)(m.anything()).then((input)->ruleEntry)
        jm.when(ruleEntry.getRule)(m.anything()).then((input)->"LOOKED UP RULE")
      )
      test("Asset has no actions collection - returns array with backbone model named 'finish' only", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(), game)
        a(acts.length, 1)
        a(acts[0].get("name"),"finish")
      )
      test("Asset has empty actions collection - returns array with backbone model named 'finish' only", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          action:new Backbone.Collection()
        ), game)
        a(acts.length, 1)
        a(acts[0].get("name"),"finish")
      )
      test("Asset has actions collection with actions with no types - returns backbone model named for each action with 'finish' on the end", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
          ,
            name:"ACTION2"
          ,
            name:"ACTION3"
          ])
        ), game)
        a(acts[0].get("name"),"ACTION1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[2].get("name"),"ACTION3")
        a(acts[3].get("name"),"finish")
        a(acts.length, 4)
      )
      test("Asset has actions collection with actions with types - returns names of types for actions with types", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
          ,
            name:"ACTION2"
          ,
            name:"ACTION3"
            types:new Backbone.Collection([
              name:"ACTION3-TYPE1"
            ,
              name:"ACTION3-TYPE2"
            ])
          ])
        ), game)
        a(acts.length, 5)
        a(acts[0].get("name"),"ACTION1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[2].get("name"),"ACTION3-TYPE1")
        a(acts[3].get("name"),"ACTION3-TYPE2")
        a(acts[4].get("name"),"finish")
      )
      test("Asset has actions collection with actions with empty types - omits action", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
          ,
            name:"ACTION2"
          ,
            name:"ACTION3"
            types:new Backbone.Collection([])
          ])
        ), game)
        a(acts.length, 3)
        a(acts[0].get("name"),"ACTION1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[2].get("name"),"finish")
      )
      test("Unnamed actions - returns blank names", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
          ,
            {}
          ,
            name:"ACTION3"
            types:new Backbone.Collection([
              {}
            ,
              name:"ACTION3-TYPE2"
            ])
          ])
        ), game)
        a(acts.length, 5)
        a(acts[0].get("name"),"ACTION1")
        a(acts[1].get("name"),m.nil())
        a(acts[2].get("name"),m.nil())
        a(acts[3].get("name"),"ACTION3-TYPE2")
        a(acts[4].get("name"),"finish")
      )
      test("Invalid actions - sdds blank name action", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            "ACTION1"
          ,

            name:"ACTION2"
          ,
            name:"ACTION3"
            types:new Backbone.Collection([
              {}
            ,
              name:"ACTION3-TYPE2"
            ])
          ])
        ), game)

        a(acts[0].get("name"),m.nil())
        a(acts[1].get("name"),"ACTION2")
        a(acts[2].get("name"),m.nil())
        a(acts[3].get("name"),"ACTION3-TYPE2")
        a(acts[4].get("name"),"finish")
      )
      test("Action with invalid types collection - throws", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              name:"ACTION1"
            ,
              name:"ACTION2"
            ,
              name:"ACTION3"
              types:{}
            ])
          ), game)
        ,
          m.raisesAnything()
        )
      )
      test("Action with invalid entries in types collection - throws", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
          ,
            name:"ACTION2"
          ,
            name:"ACTION3"
            types:new Backbone.Collection([
              "INVALID"
            ,
              name:"ACTION3-TYPE2"
            ])
          ])
        ), game)

        a(acts[0].get("name"),"ACTION1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[2].get("name"),m.nil())
        a(acts[3].get("name"),"ACTION3-TYPE2")
        a(acts[4].get("name"),"finish")
      )
    )
  )
)

