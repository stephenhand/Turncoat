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
        processor = null
        setup(()->
          jm.when(ModelProcessor.recurse)(m.anything(),m.func(),ModelProcessor.PREORDER).then((m,p,o)->
            processor = p
          )

        )

      )
    )
  )


)

