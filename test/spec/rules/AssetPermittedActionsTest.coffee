require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/Action", "rules/AssetPermittedActions", (actual, modulePath, requestingModulePath)->
    Backbone.Model.extend({})
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
      test("Asset has actions collection with actions with no types - returns backbone model named for each action with 'finish' on the end, copying the rules", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
            rule:"RULE1"
          ,
            name:"ACTION2"
            rule:"RULE2"
          ,
            name:"ACTION3"
            rule:"RULE3"
          ])
        ), game)
        a(acts[0].get("name"),"ACTION1")
        a(acts[0].get("rule"),"RULE1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[1].get("rule"),"RULE2")
        a(acts[2].get("name"),"ACTION3")
        a(acts[2].get("rule"),"RULE3")
        a(acts[3].get("name"),"finish")
        a(acts.length, 4)
      )
      test("Asset has actions collection with actions with types - returns names of types for actions with types, copying rules", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
            rule:"RULE1"
          ,
            name:"ACTION2"
            rule:"RULE2"
          ,
            name:"ACTION3"
            rule:"RULE3"
            types:new Backbone.Collection([
              name:"ACTION3-TYPE1"
              rule:"RULE4"
            ,
              name:"ACTION3-TYPE2"
              rule:"RULE5"
            ])
          ])
        ), game)
        a(acts.length, 5)
        a(acts[0].get("name"),"ACTION1")
        a(acts[0].get("rule"),"RULE1")
        a(acts[1].get("name"),"ACTION2")
        a(acts[1].get("rule"),"RULE2")
        a(acts[2].get("name"),"ACTION3-TYPE1")
        a(acts[2].get("rule"),"RULE4")
        a(acts[3].get("name"),"ACTION3-TYPE2")
        a(acts[3].get("rule"),"RULE5")
        a(acts[4].get("name"),"finish")
      )
      test("Asset has actions collection with actions with empty types - omits action", ()->
        acts = AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
            rule:"RULE"
          ,
            name:"ACTION2"
            rule:"RULE"
          ,
            name:"ACTION3"
            rule:"RULE"
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
            rule:"RULE"
          ,

            rule:"RULE"
          ,
            name:"ACTION3"
            rule:"RULE"
            types:new Backbone.Collection([

              rule:"RULE"
            ,
              name:"ACTION3-TYPE2"
              rule:"RULE"
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
      test("Missing rules - throws", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              name:"ACTION1"
            ,

              name:"ACTION3"
              rule:"RULE"
            ,
              name:"ACTION3"
              rule:"RULE"
              types:new Backbone.Collection([

                name:"ACTION3-TYPE2"
                rule:"RULE"
              ,
                name:"ACTION3-TYPE2"
                rule:"RULE"
              ])
            ])
          ), game)
        ,
          m.raisesAnything()
        )
      )
      test("Missing rules on action with types - does not throw", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              name:"ACTION1"
              rule:"RULE"
            ,

              name:"ACTION3"
              rule:"RULE"
            ,
              name:"ACTION3"
              types:new Backbone.Collection([
                rule:"RULE"
                name:"ACTION3-TYPE2"
              ,
                name:"ACTION3-TYPE2"
                rule:"RULE"
              ])
            ])
          ), game)
        ,
          m.not(m.raisesAnything())
        )
      )
      test("Missing rules on types - throws", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              name:"ACTION1"
              rule:"RULE"
            ,

              name:"ACTION3"
              rule:"RULE"
            ,
              name:"ACTION3"
              rule:"RULE"
              types:new Backbone.Collection([

                name:"ACTION3-TYPE2"
              ,
                name:"ACTION3-TYPE2"
                rule:"RULE"
              ])
            ])
          ), game)
        ,
          m.raisesAnything()
        )
      )
      test("Invalid actions - throws", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              "ACTION1"
            ,

              name:"ACTION3"
              rule:"RULE"
            ,
              name:"ACTION3"
              rule:"RULE"
              types:new Backbone.Collection([

                name:"ACTION3-TYPE2"
              ,
                name:"ACTION3-TYPE2"
                rule:"RULE"
              ])
            ])
          ), game)
        , m.raisesAnything()
        )
      )
      test("Action with invalid types collection - throws", ()->
        a(()->
          AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
            actions:new Backbone.Collection([
              name:"ACTION1"
              rule:"RULE"
            ,
              name:"ACTION2"
              rule:"RULE"
            ,
              name:"ACTION3"
              rule:"RULE"
              types:{}
            ])
          ), game)
        ,
          m.raisesAnything()
        )
      )

    )
    test("Action with invalid entries in types collection - throws", ()->
      a(()->
        AssetPermittedActions.getPermittedActionsForAsset(new Backbone.Model(
          actions:new Backbone.Collection([
            name:"ACTION1"
            rule:"RULE"
          ,

            name:"ACTION3"
            rule:"RULE"
          ,
            name:"ACTION3"
            rule:"RULE"
            types:new Backbone.Collection([

              "ACTION3-TYPE2"
            ,
              name:"ACTION3-TYPE2"
              rule:"RULE"
            ])
          ])
        ), game)
      ,
        m.raisesAnything()
      )
    )
  )
)


