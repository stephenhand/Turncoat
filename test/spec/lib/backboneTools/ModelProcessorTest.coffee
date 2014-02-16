define(["isolate!lib/backboneTools/ModelProcessor", "jsMockito", "jsHamcrest", "chai"], (ModelProcessor, jm, h, c)->
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ModelProcessor", ()->
    modelWithModelChildrenOfBackboneCollections = null
    modelWithNestedCollections = null
    
    suite("recurse", ()->
      recurser = null
      setup(()->
        recurser = jm.mockFunction()
        jm.when(recurser)(m.anything()).then(()->true)
      )
      suite("Model with no sub models", ()->
        modelWithNoSubmodels = null
        setup(()->
          modelWithNoSubmodels = new Backbone.Model(
            a:
              val:8
            b:
              val:7
          )
        )
        test("Calls recurser function on model",()->
          ModelProcessor.recurse(modelWithNoSubmodels, recurser)
          jm.verify(recurser)(modelWithNoSubmodels)
        )
        test("Ignores directly referenced models & collections",()->
          modelWithNoSubmodels.aModel = new Backbone.Model()
          modelWithNoSubmodels.aCollection = new Backbone.Collection()
          ModelProcessor.recurse(modelWithNoSubmodels, recurser)
          jm.verify(recurser, v.never())(modelWithNoSubmodels.aModel)
          jm.verify(recurser, v.never())(modelWithNoSubmodels.aCollection)
        )
        test("Preorder traversal - Same as inorder",()->
          ModelProcessor.recurse(modelWithNoSubmodels, recurser, ModelProcessor.PREORDER)
          jm.verify(recurser)(modelWithNoSubmodels)
        )
      )
      suite("Collection with no sub models", ()->

        collectionWithNoSubmodels = null
        setup(()->
          collectionWithNoSubmodels = new Backbone.Collection()
        )
        test("Calls recurser function on collection",()->
          ModelProcessor.recurse(collectionWithNoSubmodels, recurser)
          jm.verify(recurser)(collectionWithNoSubmodels)
        )
        test("Ignores directly referenced models & collections",()->
          collectionWithNoSubmodels.aModel = new Backbone.Model()
          collectionWithNoSubmodels.aCollection = new Backbone.Collection()
          ModelProcessor.recurse(collectionWithNoSubmodels, recurser)
          jm.verify(recurser, v.never())(collectionWithNoSubmodels.aModel)
          jm.verify(recurser, v.never())(collectionWithNoSubmodels.aCollection)
        )
        test("Preorder traversal - Same as inorder",()->
          ModelProcessor.recurse(collectionWithNoSubmodels, recurser, ModelProcessor.PREORDER)
          jm.verify(recurser)(collectionWithNoSubmodels)
        )
      )
      suite("Collection containing models", ()->

        collectionWithModels = null
        setup(()->
          collectionWithModels = new Backbone.Collection([
            new Backbone.Model()
          ,
            new Backbone.Model()
          ,
            new Backbone.Model()
          ])
        )
        test("Calls recurser function on collection and all items",()->
          ModelProcessor.recurse(collectionWithModels, recurser)
          jm.verify(recurser)(collectionWithModels)
          jm.verify(recurser)(collectionWithModels.at(0))
          jm.verify(recurser)(collectionWithModels.at(1))
          jm.verify(recurser)(collectionWithModels.at(2))
        )
        suite("Recurser returns false partway through a collection", ()->
          test("In order traversal - processes root and items prior to collection",()->
            jm.when(recurser)(m.anything()).then((item)->
              if item is collectionWithModels.at(1) then false else true
            )
            ModelProcessor.recurse(collectionWithModels, recurser)
            jm.verify(recurser)(collectionWithModels)
            jm.verify(recurser)(collectionWithModels.at(0))
            jm.verify(recurser)(collectionWithModels.at(1))
          )
          test("Pre order traversal - same as in order",()->
            jm.when(recurser)(m.anything()).then((item)->
              if item is collectionWithModels.at(1) then false else true
            )
            ModelProcessor.recurse(collectionWithModels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(collectionWithModels)
            jm.verify(recurser)(collectionWithModels.at(0))
            jm.verify(recurser)(collectionWithModels.at(1))
          )
        )
      )
      suite("Model with 1 level of sub models", ()->

        modelWith1LevelSubmodels = null
        setup(()->

          modelWith1LevelSubmodels = new Backbone.Model(
            a:new Backbone.Model()
            b:new Backbone.Model()
          )
        )
        test("Calls recurser function on children and root",()->
          ModelProcessor.recurse(modelWith1LevelSubmodels, recurser)
          jm.verify(recurser)(modelWith1LevelSubmodels)
          jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
          jm.verify(recurser)(modelWith1LevelSubmodels.get("b"))
        )
        suite("Root returns false", ()->
          test("In order traversal - calls recurser function on children and root",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith1LevelSubmodels.get("b"))
          )
          test("Pre order traversal - calls recurser function on root only",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser, v.never())(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser, v.never())(modelWith1LevelSubmodels.get("b"))
          )
          test("No traversal specified - treated as in order",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith1LevelSubmodels.get("b"))
          )
        )
        suite("First child returns false",()->
          test("In order traveral - calls recurser function on first child and ancestors (i.e. the root)",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels.get("a") then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser, v.never())(modelWith1LevelSubmodels.get("b"))
          )
          test("Pre order traveral - same as in order.",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels.get("a") then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser, v.never())(modelWith1LevelSubmodels.get("b"))
          )
        )
        suite("Last child returns false", ()->
          test("In order traversal - calls recurser function on all nodes",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels.get("b") then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith1LevelSubmodels.get("b"))
          )
          test("Pre order traversal - calls recurser function on all nodes",()->

            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith1LevelSubmodels.get("b") then false else true
            )
            ModelProcessor.recurse(modelWith1LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith1LevelSubmodels)
            jm.verify(recurser)(modelWith1LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith1LevelSubmodels.get("b"))
          )
        )
      )
      suite("Model with 3 levels of sub models", ()->

        modelWith3LevelSubmodels = null
        setup(()->
          modelWith3LevelSubmodels = new Backbone.Model(
            a:new Backbone.Model(
              c:new Backbone.Model(
                f:new Backbone.Model()
              )
              d:new Backbone.Model(
                g:new Backbone.Model()
                h:new Backbone.Model()
              )
              dd:{}
              e:new Backbone.Model()
            )
            b:new Backbone.Model()
          )
        )
        suite("Recurser always returns true", ()->
          test("In order traversal - recurses all models that form tree", ()->
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("g"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("b"))
          )
          test("Pre order traversal - recurses all models that form tree", ()->
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("g"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("b"))
          )
        )
        test("Omits non models", ()->
          ModelProcessor.recurse(modelWith3LevelSubmodels, recurser)
          jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("dd"))
        )
        test("Omits models that are referenced by non models", ()->
          modelWith3LevelSubmodels.get("a").set("dd",
            ddd:new Backbone.Model()
            dde:new Backbone.Model()
          )
          ModelProcessor.recurse(modelWith3LevelSubmodels, recurser)
          jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("dd").ddd)
          jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("dd").dde)
        )
        suite("Intermediate model returns false", ()->
          test("In order traversal - recurses all children and ancestors of node, but no further siblings of node or further siblings of ancestor nodes", ()->
            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith3LevelSubmodels.get("a").get("d") then false else true
            )
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("g"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("b"))
          )
          test("Pre order traversal - recurses node and ancestors of node only, no further siblings or children", ()->
            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith3LevelSubmodels.get("a").get("d") then false else true
            )
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("d").get("g"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("b"))
          )
        )
        suite("Recusion modifies children of node", ()->

          test("In order traversal - recurses tree prior to modification", ()->
            oldG = modelWith3LevelSubmodels.get("a").get("d").get("g")
            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith3LevelSubmodels.get("a").get("d")
                item.unset("g")
                item.set("i", new Backbone.Model())
              true
            )
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.INORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser)(oldG)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser, v.never())(modelWith3LevelSubmodels.get("a").get("d").get("i"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("b"))
          )
          test("Pre order traversal - recurses tree following modification", ()->
            oldG = modelWith3LevelSubmodels.get("a").get("d").get("g")
            jm.when(recurser)(m.anything()).then((item)->
              if item is modelWith3LevelSubmodels.get("a").get("d")
                item.unset("g")
                item.set("i", new Backbone.Model())
              true
            )
            ModelProcessor.recurse(modelWith3LevelSubmodels, recurser, ModelProcessor.PREORDER)
            jm.verify(recurser)(modelWith3LevelSubmodels)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("c").get("f"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d"))
            jm.verify(recurser, v.never())(oldG)
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("h"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("d").get("i"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("a").get("e"))
            jm.verify(recurser)(modelWith3LevelSubmodels.get("b"))
          )
        )
      )

      suite("Mixed structure of collections and models", ()->

        modelWithNestedCollections = null
        setup(()->
          modelWithNestedCollections = new Backbone.Model(
            a:new Backbone.Model()
            b:new Backbone.Collection([
              new Backbone.Model(
                bb:new Backbone.Collection([
                  new Backbone.Model()
                  new Backbone.Model()
                ])
                bc:{val:14}
              )
              new Backbone.Model()
              new Backbone.Model()
            ])
            c:new Backbone.Model()
          )
        )
        test("In order - Calls recurser function on all models and collections",()->
          ModelProcessor.recurse(modelWithNestedCollections, recurser, ModelProcessor.INORDER)
          jm.verify(recurser)(modelWithNestedCollections)
          jm.verify(recurser)(modelWithNestedCollections.get("a"))
          jm.verify(recurser)(modelWithNestedCollections.get("b"))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb"))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb").at(0))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb").at(1))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(1))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(2))
          jm.verify(recurser)(modelWithNestedCollections.get("c"))
        )
        test("Pre order - Calls recurser function on all models and collections",()->
          ModelProcessor.recurse(modelWithNestedCollections, recurser, ModelProcessor.PREORDER)
          jm.verify(recurser)(modelWithNestedCollections)
          jm.verify(recurser)(modelWithNestedCollections.get("a"))
          jm.verify(recurser)(modelWithNestedCollections.get("b"))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb"))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb").at(0))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(0).get("bb").at(1))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(1))
          jm.verify(recurser)(modelWithNestedCollections.get("b").at(2))
          jm.verify(recurser)(modelWithNestedCollections.get("c"))
        )
      )
    )
    suite("deepUpdate", ()->
      ModelType1 = Backbone.Model.extend()
      ModelType2 = Backbone.Model.extend()
      CollectionType1 = Backbone.Collection.extend()
      CollectionType2 = Backbone.Collection.extend()
      origRecurse = ModelProcessor.recurse
      setup(()->
        ModelProcessor.recurse = jm.mockFunction()
      )
      teardown(()->
        ModelProcessor.recurse = origRecurse
      )
      test("Target is not Backbone model or Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate({}, new Backbone.Model())
        )
      )
      test("Updated model is not Backbone model or Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Model(), {})
        )
      )
      test("Target is Model but updated is Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Model(), new Backbone.Collection())
        )
      )
      test("Target is Collection but updated is Model - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Collection(), new Backbone.Model())
        )
      )
      test("Target is Model but updated is Collection - throws", ()->
        a.throws(()->
          ModelProcessor.deepUpdate(new Backbone.Model(), new Backbone.Collection())
        )
      )
      test("Target and update are different derivations of models - doesn't throw", ()->
        a.doesNotThrow(()->
          ModelProcessor.deepUpdate(new ModelType1(), new ModelType2())
        )
      )
      test("Target and update are different derivations of collections - doesn't throw", ()->
        a.doesNotThrow(()->
          ModelProcessor.deepUpdate(new CollectionType1(), new CollectionType2())
        )
      )
      test("Returns target model", ()->
        t = new Backbone.Model()
        a.strictEqual(t, ModelProcessor.deepUpdate(t,new Backbone.Model()))
      )
      test("Calls recurse on target as preorder", ()->
        t = new Backbone.Model()
        ModelProcessor.deepUpdate(t,new Backbone.Model())
        jm.verify(ModelProcessor.recurse)(t,m.func(),ModelProcessor.PREORDER)
      )
      suite("Processing function", ()->
        ca = null
        cb = null
        cc = null
        cd = null
        ce = null
        cf = null
        cg = null
        t=null
        bObj = {x:2}
        setup(()->
          ModelProcessor.recurse = origRecurse
          ca = jm.mockFunction()
          cb = jm.mockFunction()
          cc = jm.mockFunction()
          cd = jm.mockFunction()
          ce = jm.mockFunction()
          cf = jm.mockFunction()
          cg = jm.mockFunction()
          t = new Backbone.Model(
            a:"A"
            b:bObj
            c:456
            d:null
            e:false
            f:undefined
          )

        )
        suite("Model with no sub models", ()->
          setup(()->
            t.on("change:a", ca)
            t.on("change:b", cb)
            t.on("change:c", cc)
            t.on("change:d", cd)
            t.on("change:e", ce)
            t.on("change:f", cf)
            t.on("change:g", cg)
          )
          test("Truthy properties updated with new falsey values set values to updated values and fire change events", ()->
            u = new Backbone.Model(
              a:null
              b:false
              c:undefined
              d:null
              e:false
              f:undefined
            )
            ModelProcessor.deepUpdate(t, u)
            a.isNull(t.get("a"))
            a.isFalse(t.get("b"))
            a.isUndefined(t.get("c"))
            jm.verify(ca)()
            jm.verify(cb)()
            jm.verify(cc)()
          )
          test("Falsey properties updated with new truthy values set values to updated exact values and fire change events", ()->
            u = new Backbone.Model(
              a:"A"
              b:bObj
              c:456
              d:"A"
              e:bObj
              f:456
            )
            ModelProcessor.deepUpdate(t, u)
            a.strictEqual(t.get("d"), "A")
            a.strictEqual(t.get("e"),bObj)
            a.strictEqual(t.get("f"), 456)
            jm.verify(cd)()
            jm.verify(ce)()
            jm.verify(cf)()
          )
          test("Truthy properties updated with new truthy values set values to updated values and fire change events", ()->
            u = new Backbone.Model(
              a:"B"
              b:{x:1}
              c:123
              d:null
              e:false
              f:undefined
            )
            ModelProcessor.deepUpdate(t, u)
            a.equal(t.get("a"), "B")
            a.equal(t.get("b"), u.get("b"))
            a.equal(t.get("c"), 123)
            jm.verify(ca)()
            jm.verify(cb)()
            jm.verify(cc)()
          )
          test("Falsey properties updated with new falsey values set values to updated exact values and fire change events", ()->
            u = new Backbone.Model(
              a:"A"
              b:bObj
              c:456
              d:false
              e:undefined
              f:null
            )
            ModelProcessor.deepUpdate(t, u)
            a.isFalse(t.get("d"))
            a.isUndefined(t.get("e"))
            a.isNull(t.get("f"))
            jm.verify(cd)()
            jm.verify(ce)()
            jm.verify(cf)()
          )
          test("Matching properties don't change or fire", ()->
            u = new Backbone.Model(
              a:"A"
              b:bObj
              c:456
              d:null
              e:false
              f:undefined
            )
            ModelProcessor.deepUpdate(t, u)
            a.strictEqual(t.get("a"), "A")
            a.strictEqual(t.get("b"),bObj)
            a.strictEqual(t.get("c"), 456)
            a.isNull(t.get("d"))
            a.isFalse(t.get("e"))
            a.isUndefined(t.get("f"))
            jm.verify(ca, v.never())()
            jm.verify(cb, v.never())()
            jm.verify(cc, v.never())()
            jm.verify(cd, v.never())()
            jm.verify(ce, v.never())()
            jm.verify(cf, v.never())()
          )
          test("Deep matching simple objects don't fire", ()->
            u = new Backbone.Model(
              a:"B"
              b:{x:2}
              c:123
              d:null
              e:false
              f:undefined
            )
            ModelProcessor.deepUpdate(t, u)
            a.strictEqual(t.get("b"), u.get("b"))
            jm.verify(cb, v.never())()
          )
          test("Attributes in target that are not present in update are removed from target and fires", ()->
            u = new Backbone.Model(
              a:"B"
              c:123
              d:null
              f:undefined
            )
            ModelProcessor.deepUpdate(t, u)
            a.isUndefined(t.get("b"))
            jm.verify(cb)()
            a.isUndefined(t.get("e"))
            jm.verify(ce)()
          )
          test("Attributes in update that are not present in target are added to target and fire events", ()->
            u = new Backbone.Model(
              a:"B"
              c:123
              d:null
              f:undefined
              g:"SOMETHING NEW"

            )
            ModelProcessor.deepUpdate(t, u)
            a.isUndefined(t.get("b"))
            jm.verify(cb)()
            a.isUndefined(t.get("e"))
            jm.verify(ce)()
            a.equal(t.get("g"),"SOMETHING NEW")
            jm.verify(cg)()
          )
        )
        suite("Model with single level of sub models", ()->
          t = null
          u = null
          t1 = null
          t2 = null
          u1 = null
          u2 = null
          cda = null
          cdc = null
          setup(()->
            cda = jm.mockFunction()
            cdc = jm.mockFunction()
            t1 = new Backbone.Model(
              id:"SUBMODEL1"
              a:1
              b:2
            )
            t2 = new Backbone.Model(
              id:"SUBMODEL2"
              a:3
              b:4
            )
            t = new Backbone.Model(
              a:"A"
              b:t2
              c:456
              d:t1
              e:false
              f:null
            )
            u1 = new Backbone.Model(
              id:"SUBMODEL1"
              a:3
              b:2
              c:1
            )
            u2 = new Backbone.Model(
              id:"NOT SUBMODEL2"
              a:3
              b:4
            )
            u = new Backbone.Model(
              a:"A"
              b:u2
              c:123
              d:u1
              e:false
              g:"SOMETHING"
            )
            t.on("change:a", ca)
            t.on("change:b", cb)
            t.on("change:c", cc)
            t.on("change:d", cd)
            t.on("change:e", ce)
            t.on("change:f", cf)
            t.on("change:g", cg)
            t1.on("change:a", cda)
            t1.on("change:c", cdc)
          )
          test("Still updates non model/collection properties and fires events", ()->

            ModelProcessor.deepUpdate(t, u)
            a.strictEqual(t.get("a"), "A")
            a.strictEqual(t.get("c"), 123)
            a.isFalse(t.get("e"))
            a.isUndefined(t.get("f"))
            a.equal(t.get("g"),"SOMETHING")

            jm.verify(cc)()
            jm.verify(cf)()
            jm.verify(cg)()
          )
          test("Replaces models where ids don't match and fires event on owner model", ()->

            ModelProcessor.deepUpdate(t, u)
            a.equal(t.get("b"), u2)
            jm.verify(cb)()
          )
          test("Preserves models where ids match, updating individual attributes of that model which are different, firing events on child model", ()->

            ModelProcessor.deepUpdate(t, u)
            a.strictEqual(t.get("d"), t1)
            a.strictEqual(t1.get("a"), 3)
            a.strictEqual(t1.get("b"), 2)
            a.strictEqual(t1.get("c"), 1)
            jm.verify(cda)()
            jm.verify(cdc)()
          )
          test("Removes models from target that aren't present in update", ()->
            u.unset("b")

            u.unset("d")
            ModelProcessor.deepUpdate(t, u)
            a.isUndefined(t.get("b"))
            a.isUndefined(t.get("d"))
            jm.verify(cb)()
            jm.verify(cd)()
          )
          test("Adds models to target that are new in update", ()->
            new1 = new Backbone.Model()
            u.set("g", new1)

            ModelProcessor.deepUpdate(t, u)
            a.equal(t.get("g"), new1)
            jm.verify(cg)()
          )
          suite("Deeper nested set of models", ()->
            t11 = null
            t12 = null
            t21 = null
            u11 = null
            u12 = null
            u21 = null
            cdda = null
            cddb = null
            cde = null
            setup(()->
              cdda = jm.mockFunction()
              cddb = jm.mockFunction()
              cde = jm.mockFunction()
              t11 = new Backbone.Model(
                id:"SUBMODEL 1 SUBMODEL 1"
                a:34
                b:45
              )
              t12 = new Backbone.Model(
                id:"SUBMODEL 1 SUBMODEL 2"
                a:34
                b:45
              )
              t21 = new Backbone.Model(

              )
              u11 = new Backbone.Model(
                id:"SUBMODEL 1 SUBMODEL 1"
                a:345
                b:456
              )
              u12 = new Backbone.Model(
                id:"DIFFERENT ID"
                a:123
                b:234
              )
              u21 = new Backbone.Model(

              )
              t1.set(
                d:t11
                e:t12
              )
              u1.set(
                d:u11
                e:u12
              )
              t11.on("change:a", cdda)
              t11.on("change:b", cddb)

              t1.on("change:e", cde)
            )
            test("Model graph has matching ids through to leaf - preserves all models and sets changed properties on all nodes from root to leaf", ()->
              ModelProcessor.deepUpdate(t, u)
              a.strictEqual(t.get("d"), t1)
              a.strictEqual(t1.get("a"), 3)
              a.strictEqual(t1.get("b"), 2)
              a.strictEqual(t1.get("c"), 1)
              a.strictEqual(t1.get("d"), t11)
              a.strictEqual(t11.get("a"), 345)
              a.strictEqual(t11.get("b"), 456)
              jm.verify(cda)()
              jm.verify(cdc)()
              jm.verify(cdda)()
              jm.verify(cddb)()
            )
            test("Model graph has matching ids through to intermediate node - preserves all models up to changed node, that node and all descendents are new.", ()->
              ModelProcessor.deepUpdate(t, u)
              a.strictEqual(t.get("d"), t1)
              a.strictEqual(t1.get("a"), 3)
              a.strictEqual(t1.get("b"), 2)
              a.strictEqual(t1.get("c"), 1)
              a.strictEqual(t1.get("d"), t11)
              a.strictEqual(t11.get("a"), 345)
              a.strictEqual(t11.get("b"), 456)
              a.strictEqual(t1.get("e"), u12)
              jm.verify(cda)()
              jm.verify(cdc)()
              jm.verify(cdda)()
              jm.verify(cddb)()
              jm.verify(cde)()
            )
          )
        )

        suite("Single collection", ()->
          ia = null
          ib= null
          ic = null
          id = null
          add = null
          remove = null
          reset = null
          setup(()->
            add = jm.mockFunction()
            remove = jm.mockFunction()
            reset = jm.mockFunction()
            ia = new Backbone.Model(
              id:"A"
            )
            ib = new Backbone.Model(
              id:"B"
            )
            ic = new Backbone.Model(
              id:"C"
            )
            id = new Backbone.Model(
              id:"D"
            )
            t = new Backbone.Collection([
              ia
            ,
              ib
            ,
              ic
            ,
              id
            ])

            t.on("add", add)
            t.on("remove", remove)
            t.on("reset", reset)
          )
          test("Matching models don't change or fire", ()->
            u = new Backbone.Collection([
              ia
            ,
              ib
            ,
              ic
            ,
              id
            ])
            ModelProcessor.deepUpdate(t, u)
            a.equal(t.at(0), ia)
            a.equal(t.at(1), ib)
            a.equal(t.at(2), ic)
            a.equal(t.at(3), id)
            a.equal(t.length, 4)
            jm.verify(add, v.never())()
            jm.verify(remove, v.never())()
            jm.verify(reset, v.never())()
          )
          test("New models are added to existing colection and fire add events", ()->
            uie = new Backbone.Model(id:"E")
            u = new Backbone.Collection([
              ia
            ,
              ib
            ,
              uie
            ,
              ic
            ,
              id
            ])
            ModelProcessor.deepUpdate(t, u)
            a.include(t.models, ia)
            a.include(t.models, ib)
            a.include(t.models, uie)
            a.include(t.models, ic)
            a.include(t.models, id)
            a.equal(t.length, 5)
            jm.verify(add)()
            jm.verify(remove, v.never())()
            jm.verify(reset, v.never())()
          )
          test("Models missing in update are removed from existing colection and fire remove events", ()->
            uie = new Backbone.Model(id:"E")
            u = new Backbone.Collection([
              ia
            ,
              ic
            ,
              id
            ])
            ModelProcessor.deepUpdate(t, u)
            a.include(t.models, ia)
            a.include(t.models, ic)
            a.include(t.models, id)
            a.equal(t.length, 3)
            jm.verify(add, v.never())()
            jm.verify(remove)()
            jm.verify(reset, v.never())()
          )
          test("Models different in update result in adds and removes being applied to existing colection and appropriate events being fired", ()->
            uie = new Backbone.Model(id:"E")
            uif = new Backbone.Model(id:"F")
            u = new Backbone.Collection([
              ia
            ,
              uie
            ,
              ic
            ,
              id
            ,
              uif
            ])
            ModelProcessor.deepUpdate(t, u)
            a.include(t.models, ia)
            a.include(t.models, ic)
            a.include(t.models, id)
            a.include(t.models, uie)
            a.include(t.models, uif)
            a.equal(t.length, 5)
            jm.verify(add, v.times(2))()
            jm.verify(remove)()
            jm.verify(reset, v.never())()
          )
          test("No comparator on model - order not preserved", ()->
            uie = new Backbone.Model(id:"E")
            uif = new Backbone.Model(id:"F")
            u = new Backbone.Collection([
              ia
            ,
              uie
            ,
              ic
            ,
              id
            ,
              uif
            ])
            ModelProcessor.deepUpdate(t, u)
            a.equal(t.at(0), ia)
            a.equal(t.at(1), ic)
            a.equal(t.at(2), id)
            a.equal(t.at(3), uie)
            a.equal(t.at(4), uif)
            a.equal(t.length, 5)
            jm.verify(add, v.times(2))()
            jm.verify(remove)()
            jm.verify(reset, v.never())()
          )
        )
      )
    )
  )


)

