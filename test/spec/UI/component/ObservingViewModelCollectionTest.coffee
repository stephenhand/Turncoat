define(["isolate!UI/component/ObservingViewModelCollection", "backbone", "jsMockito", "jsHamcrest", "chai"], (ObservingViewModelCollection, Backbone, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/ReviewChallengesViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ObservingViewModelCollection", ()->
    coll1 = coll2 = coll3 = coll4 = coll5 = null
    bvmc=null
    mockOnSourceUpdatedHandler = null
    mockOnSourceUpdatedHandler2 = null
    onsourceupdatedHandlerMatcher = null
    setup(()->
      invokes = 0
      mockOnSourceUpdatedHandler = JsMockito.mockFunction()
      onsourceupdatedHandlerMatcher = new JsHamcrest.SimpleMatcher(
        describeTo:(d)->"OnSourceUpdated Handler"
        matches:(input)->
          bvmc.onSourceUpdated = jm.mockFunction()

          input(
            oldModels:[]
            models:[]
          )
          try
            jm.verify(bvmc.onSourceUpdated)()
            true
          catch e
            false
      )
      onsourceupdatedHandlerMatcher.handlerToCheck=mockOnSourceUpdatedHandler
      bvmc = new ObservingViewModelCollection()
      bvmc.onSourceUpdated = mockOnSourceUpdatedHandler

      coll1 = {}
      _.extend(coll1, Backbone.Events)
      coll1.on=jm.mockFunction()
      coll1.off=jm.mockFunction()
      coll1.models=[]
      coll2 =
        on:jm.mockFunction()
        off:jm.mockFunction()
        models:[]
      coll3 =
        on:jm.mockFunction()
        off:jm.mockFunction()
        models:[]
      coll4 =
        on:jm.mockFunction()
        off:jm.mockFunction()
        models:[]
      coll5 =
        on:jm.mockFunction()
        off:jm.mockFunction()
        models:[]
    )
    suite("watch", ()->
      popCol1 = null
      setup(()->
        popCol1 = new Backbone.Collection([
          propA:"1A1"
          propB:"1B1"
          propC:"1C1"
        ,
          propA:"1A2"
          propB:"1B2"
          propC:"1C2"
        ,
          propA:"1A2"
          propB:"1B2"
          propC:"1C2"
        ,
        ])
        popCol1.at(0).on = jm.mockFunction()
        popCol1.at(1).on = jm.mockFunction()
        popCol1.at(2).on = jm.mockFunction()
      )
      test("singleCollection_DoesntDupBinds", ()->
        bvmc.watch([coll1])
        bvmc.watch([coll1])
        JsMockito.verify(coll1.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
      )
      test("multipleCollections_DoesntDupBinds", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.watch([coll2,coll3,coll4])
        JsMockito.verify(coll2.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.on, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
      )
      test("reassigningHandlerAfterWatch_CallsUpdatedHandler", ()->

        mockOnSourceUpdatedHandler2 = JsMockito.mockFunction()
        mockOnSourceUpdatedHandler3 = JsMockito.mockFunction()
        coll = {}
        _.extend(coll, Backbone.Events)
        coll.models=[]
        bvmc.watch([coll])
        bvmc.onSourceUpdated = mockOnSourceUpdatedHandler2
        coll.trigger("reset",coll)
        jm.verify(mockOnSourceUpdatedHandler2)()
        bvmc.onSourceUpdated = mockOnSourceUpdatedHandler3
        coll.trigger("reset",coll)
        jm.verify(mockOnSourceUpdatedHandler3)()
      )
      suite("Model attribute events", ()->
        popCol2 = null
        setup(()->
          popCol2 = new Backbone.Collection([
            propA:"2A1"
            propB:"2B1"
          ,
            propA:"2A2"
            propB:"2B2"
          ])
          popCol2.at(0).on = jm.mockFunction()
          popCol2.at(1).on = jm.mockFunction()
        )
        test("Attributes parameter not set - doesnt bind or unbind any events on models", ()->
          bvmc.watch([popCol1])
          jm.verify(popCol1.at(0).on, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(1).on, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(2).on, v.never())(m.anything(),m.anything())

        )
        test("Attributes parameter empty - doesnt bind or unbind any events on models", ()->
          bvmc.watch([popCol1], [])
          jm.verify(popCol1.at(0).on, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(1).on, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(2).on, v.never())(m.anything(),m.anything())

        )
        test("Attributes parameter contains single existing properties - binds sourceupdated to property change event", ()->
          bvmc.watch([popCol1], ["propB"])
          jm.verify(popCol1.at(0).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propB",onsourceupdatedHandlerMatcher)

        )
        test("Attributes parameter contains multiple existing properties - binds sourceupdated to property change event for each", ()->
          bvmc.watch([popCol1], ["propB", "propC"])
          jm.verify(popCol1.at(0).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(0).on)("change:propC",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propC",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propC",onsourceupdatedHandlerMatcher)


        )
        test("Attributes parameter contains properties that don't exist - binds sourceupdated to property change event for each", ()->
          bvmc.watch([popCol1], ["propB", "propD"])
          jm.verify(popCol1.at(0).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(0).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propD",onsourceupdatedHandlerMatcher)
        )
        test("Attributes parameter contains properties that aren't strings - binds sourceupdated to property change event based on toString output", ()->
          bvmc.watch([popCol1], [
            toString:()->"OBJECTA"
          ,
            toString:()->"OBJECTB"])
          jm.verify(popCol1.at(0).on)("change:OBJECTA",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:OBJECTA",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:OBJECTA",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(0).on)("change:OBJECTB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:OBJECTB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:OBJECTB",onsourceupdatedHandlerMatcher)
        )
        test("Multiple collections - binds sourceupdated to property change event for each attribute, on each model, in each collection", ()->
          bvmc.watch([popCol1,popCol2], ["propB", "propD"])
          jm.verify(popCol1.at(0).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(0).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(1).on)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(0).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(0).on)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(1).on)("change:propD",onsourceupdatedHandlerMatcher)


        )
      )
      suite("Collection add handler", ()->
        handler = null
        model = null
        setup(()->
          model = new Backbone.Model()
          model.on = jm.mockFunction()
          popCol1.on = jm.mockFunction()
          jm.when(popCol1.on)("add", m.func()).then((a, f)->
            handler = f
          )
        )
        test("Single collection - binds OnSourceUpdated to collection add event", ()->

          bvmc.watch([coll1])
          JsMockito.verify(coll1.on)("add", onsourceupdatedHandlerMatcher)
        )
        test("Multiple collections - binds OnSourceUpdated to collections add events", ()->
          bvmc.watch([coll2,coll3,coll4])
          jm.verify(coll2.on)("add", onsourceupdatedHandlerMatcher)
          jm.verify(coll3.on)("add", onsourceupdatedHandlerMatcher)
          jm.verify(coll4.on)("add", onsourceupdatedHandlerMatcher)
        )
        test("Attributes not specified - Binds nothing to new model", ()->
          bvmc.watch([popCol1])
          handler(model)
          jm.verify(model.on, v.never())(m.anything(), m.anything())
        )
        test("Attributes specified - Binds onsourceUpdated to new model for cxhange event on each property", ()->
          bvmc.onSourceUpdated = jm.mockFunction()
          bvmc.watch([popCol1], ["A","B"])
          handler(model)
          jm.verify(model.on)("change:A", m.func())
          jm.verify(model.on)("change:B", onsourceupdatedHandlerMatcher)
        )
      )
      suite("Collection remove handler", ()->
        handler = null
        model = null
        setup(()->
          model = new Backbone.Model()
          model.off = jm.mockFunction()
          popCol1.on = jm.mockFunction()
          jm.when(popCol1.on)("remove", m.func()).then((a, f)->
            handler = f
          )
        )
        test("Single collection - binds OnSourceUpdated to collection remove event", ()->
          bvmc.watch([coll1])
          jm.verify(coll1.on)("remove", onsourceupdatedHandlerMatcher)
        )
        test("Multiple collections - binds OnSourceUpdated to collections remove events", ()->
          bvmc.watch([coll2,coll3,coll4])
          jm.verify(coll2.on)("remove", onsourceupdatedHandlerMatcher)
          jm.verify(coll3.on)("remove", onsourceupdatedHandlerMatcher)
          jm.verify(coll4.on)("remove", onsourceupdatedHandlerMatcher)
        )

        test("Attributes not specified - Binds nothing to new model", ()->
          bvmc.watch([popCol1])
          handler(model)
          jm.verify(model.off, v.never())(m.anything(), m.anything())
        )
        test("Attributes specified - Binds onsourceUpdated to new model for cxhange event on each property", ()->
          bvmc.watch([popCol1], ["A","B"])
          handler(model)
          jm.verify(model.off)("change:A", onsourceupdatedHandlerMatcher)
          jm.verify(model.off)("change:B", onsourceupdatedHandlerMatcher)
        )
      )
      suite("Collection reset handler", ()->
        handler = null
        model = null
        model2 = null
        setup(()->
          model = new Backbone.Model()
          model.on = jm.mockFunction()
          model.off = jm.mockFunction()
          model2 = new Backbone.Model()
          model2.on = jm.mockFunction()
          model2.off = jm.mockFunction()
          popCol1.on = jm.mockFunction()
          jm.when(popCol1.on)("reset", m.func()).then((a, f)->
            handler = f
          )
        )
        test("Single collection - binds OnSourceUpdated to collection reset event", ()->
          bvmc.watch([coll1])
          jm.verify(coll1.on)("reset", onsourceupdatedHandlerMatcher)
        )
        test("Multiple collections - binds onSourceUpdated to collection reset events", ()->
          bvmc.watch([coll2,coll3,coll4])
          jm.verify(coll2.on)("reset", onsourceupdatedHandlerMatcher)
          jm.verify(coll3.on)("reset", onsourceupdatedHandlerMatcher)
          jm.verify(coll4.on)("reset", onsourceupdatedHandlerMatcher)
        )

        test("Attributes not specified - Binds or unbinds nothing to new model", ()->
          bvmc.watch([popCol1])
          model.on = jm.mockFunction()
          model.off = jm.mockFunction()
          model2.on = jm.mockFunction()
          model2.off = jm.mockFunction()
          popCol1.reset([model,model2])
          handler(popCol1)
          jm.verify(model.on, v.never())("change:A", m.anything())
          jm.verify(model2.on, v.never())("change:A", m.anything())
          jm.verify(model.off, v.never())("change:A", m.anything())
          jm.verify(model2.off, v.never())("change:A", m.anything())
          jm.verify(model.on, v.never())("change:B", m.anything())
          jm.verify(model2.on, v.never())("change:B", m.anything())
          jm.verify(model.off, v.never())("change:B", m.anything())
          jm.verify(model2.off, v.never())("change:B", m.anything())
        )
        test("Attributes specified - Binds onsourceUpdated to each of new models for change event on each property", ()->
          bvmc.watch([popCol1], ["A","B"])
          popCol1.reset([model,model2])
          handler(popCol1)
          jm.verify(model.on)("change:A", onsourceupdatedHandlerMatcher)
          jm.verify(model.on)("change:B", onsourceupdatedHandlerMatcher)
          jm.verify(model2.on)("change:A", onsourceupdatedHandlerMatcher)
          jm.verify(model2.on)("change:B", onsourceupdatedHandlerMatcher)
        )
        test("Attributes specified - Unbinds that which was bound", ()->
          p0a = null
          p1a = null
          p2a = null
          p0b = null
          p1b = null
          p2b = null
          p0 = popCol1.at(0)
          p1 = popCol1.at(1)
          p2 = popCol1.at(2)
          popCol1.at(0).off = jm.mockFunction()
          popCol1.at(1).off = jm.mockFunction()
          popCol1.at(2).off = jm.mockFunction()
          jm.when(p0.on)("change:A", m.func()).then((n,f)->
            p0a = f
          )
          jm.when(p1.on)("change:A", m.func()).then((n,f)->
            p1a = f
          )
          jm.when(p2.on)("change:A", m.func()).then((n,f)->
            p2a = f
          )
          jm.when(p0.on)("change:B", m.func()).then((n,f)->
            p0b = f
          )
          jm.when(p1.on)("change:B", m.func()).then((n,f)->
            p1b = f
          )
          jm.when(p2.on)("change:B", m.func()).then((n,f)->
            p2b = f
          )
          bvmc.watch([popCol1], ["A","B"])
          popCol1.reset([model,model2])
          handler(popCol1)
          jm.verify(p0.off)("change:A", p0a)
          jm.verify(p1.off)("change:A", p1a)
          jm.verify(p2.off)("change:A", p2a)
          jm.verify(p0.off)("change:B", p0b)
          jm.verify(p1.off)("change:B", p1b)
          jm.verify(p2.off)("change:B", p2b)
        )
        test("Multiple resets - each reset binds new models and unbinds previous ones", ()->
          p0a = null
          p1a = null
          p2a = null
          p0b = null
          p1b = null
          p2b = null
          p20a = null
          p21a = null
          p20b = null
          p21b = null
          model.off = jm.mockFunction()
          model2.off = jm.mockFunction()

          p0 = popCol1.at(0)
          p1 = popCol1.at(1)
          p2 = popCol1.at(2)
          popCol1.at(0).off = jm.mockFunction()
          popCol1.at(1).off = jm.mockFunction()
          popCol1.at(2).off = jm.mockFunction()
          jm.when(p0.on)("change:A", m.func()).then((n,f)->
            p0a = f
          )
          jm.when(p1.on)("change:A", m.func()).then((n,f)->
            p1a = f
          )
          jm.when(p2.on)("change:A", m.func()).then((n,f)->
            p2a = f
          )
          jm.when(p0.on)("change:B", m.func()).then((n,f)->
            p0b = f
          )
          jm.when(p1.on)("change:B", m.func()).then((n,f)->
            p1b = f
          )
          jm.when(p2.on)("change:B", m.func()).then((n,f)->
            p2b = f
          )
          bvmc.watch([popCol1], ["A","B"])
          jm.when(model.on)("change:A", m.func()).then((n,f)->
            p20a = f
          )
          jm.when(model2.on)("change:A", m.func()).then((n,f)->
            p21a = f
          )
          jm.when(model.on)("change:B", m.func()).then((n,f)->
            p20b = f
          )
          jm.when(model2.on)("change:B", m.func()).then((n,f)->
            p21b = f
          )
          popCol1.reset([model,model2])
          handler(popCol1)
          jm.verify(p0.off)("change:A", p0a)
          jm.verify(p1.off)("change:A", p1a)
          jm.verify(p2.off)("change:A", p2a)
          jm.verify(p0.off)("change:B", p0b)
          jm.verify(p1.off)("change:B", p1b)
          jm.verify(p2.off)("change:B", p2b)
          jm.verify(model.on)("change:A", onsourceupdatedHandlerMatcher)
          jm.verify(model.on)("change:B", onsourceupdatedHandlerMatcher)
          jm.verify(model2.on)("change:A", onsourceupdatedHandlerMatcher)
          jm.verify(model2.on)("change:B", onsourceupdatedHandlerMatcher)
          popCol2 = new Backbone.Collection([
            A:"2A1"
            B:"2B1"
          ,
            A:"2A2"
            B:"2B2"
          ])
          popCol2.at(0).on = jm.mockFunction()
          popCol2.at(1).on = jm.mockFunction()
          popCol2.at(0).off = jm.mockFunction()
          popCol2.at(1).off = jm.mockFunction()
          popCol1.reset(popCol2.models)
          handler(popCol1)
          jm.verify(model.off)("change:A", p20a)
          jm.verify(model.off)("change:A", p21a)
          jm.verify(model2.off)("change:B", p20b)
          jm.verify(model2.off)("change:B", p21b)
          jm.verify(popCol2.at(0).on)("change:A", m.func())
          jm.verify(popCol2.at(1).on)("change:A", m.func())
          jm.verify(popCol2.at(0).on)("change:B", onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(1).on)("change:B", onsourceupdatedHandlerMatcher)
        )
      )

    )
    suite("unwatch", ()->
      test("Unbinds all watched collections add events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("add", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("add", onsourceupdatedHandlerMatcher)
      )
      test("Unbinds all watched collections remove events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("remove", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("remove", onsourceupdatedHandlerMatcher)
      )
      test("Unbinds all watched collections reset events", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off)("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off)("reset", onsourceupdatedHandlerMatcher)
      )
      suite("Model attribute events", ()->
        popCol1 = null
        popCol2 = null
        setup(()->
          popCol1 = new Backbone.Collection([
            propA:"1A1"
            propB:"1B1"
            propC:"1C1"
          ,
            propA:"1A2"
            propB:"1B2"
            propC:"1C2"
          ,
            propA:"1A2"
            propB:"1B2"
            propC:"1C2"
          ,
          ])
          popCol1.at(0).on = jm.mockFunction()
          popCol1.at(1).on = jm.mockFunction()
          popCol1.at(2).on = jm.mockFunction()
          popCol1.at(0).off = jm.mockFunction()
          popCol1.at(1).off = jm.mockFunction()
          popCol1.at(2).off = jm.mockFunction()
          popCol2 = new Backbone.Collection([
            propA:"2A1"
            propB:"2B1"
          ,
            propA:"2A2"
            propB:"2B2"
          ])
          popCol2.at(0).on = jm.mockFunction()
          popCol2.at(1).on = jm.mockFunction()
          popCol2.at(0).off = jm.mockFunction()
          popCol2.at(1).off = jm.mockFunction()
        )
        test("No attributes specified - unbinds nothing on models", ()->
          bvmc.watch([popCol1,popCol2])
          bvmc.unwatch()
          jm.verify(popCol1.at(0).off, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(1).off, v.never())(m.anything(),m.anything())
          jm.verify(popCol1.at(2).off, v.never())(m.anything(),m.anything())
          jm.verify(popCol2.at(0).off, v.never())(m.anything(),m.anything())
          jm.verify(popCol2.at(1).off, v.never())(m.anything(),m.anything())


        )
        test("Attributes specified in watch - unbinds all specified attributes on all models in all collections", ()->
          bvmc.watch([popCol1,popCol2], ["propB", "propD"])
          bvmc.unwatch()
          jm.verify(popCol1.at(0).off)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).off)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).off)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(0).off)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(1).off)("change:propB",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(0).off)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(1).off)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol1.at(2).off)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(0).off)("change:propD",onsourceupdatedHandlerMatcher)
          jm.verify(popCol2.at(1).off)("change:propD",onsourceupdatedHandlerMatcher)


        )
      )
      test("Empties watched collections collection", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        chai.assert.equal(bvmc.length, 0)

      )
      test("Multiple calls unbinds once", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.unwatch()
        JsMockito.verify(coll2.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll3.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)
        JsMockito.verify(coll4.off, JsMockito.Verifiers.once())("reset", onsourceupdatedHandlerMatcher)

      )
      test("emptyCollection flag not set - leaves collection in state prior to unwatch call", ()->
        bvmc.watch([coll2,coll3,coll4])
        bvmc.models = [6,4,2]
        bvmc.unwatch()
        chai.assert.deepEqual(bvmc.models, [6,4,2])

      )
      test("emptyCollection set - pops each element from collection starting at the end", ()->
        bvmc.pop= JsMockito.mockFunction()
        JsMockito.when(bvmc.pop)().then(()->bvmc.models.pop())
        bvmc.watch([coll2,coll3,coll4])
        bvmc.models = [6,4,2]
        bvmc.unwatch()
        JsMockito.verify(bvmc.pop, JsMockito.Verifiers.times(3))

      )
    )
    suite("updateFromWatchedCollection", ()->

      realCollection = null
      realCollectionThreeItems = null
      realCollectionThreeIrrelevantItems =null

      realCollectionFiveMixedItems = null
      realCollectionTwoItems = null
      realOtherCollection = null
      setup(()->
        realCollection = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollection_MOCK1"}
        ])
        realCollectionThreeItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionThreeItems_MOCK1"}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionThreeItems_MOCK2"}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionThreeItems_MOCK3"}

        ])
        realCollectionThreeIrrelevantItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionThreeIrrelevantItems_MOCK1",irrelevant:true}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionThreeIrrelevantItems_MOCK2",irrelevant:true}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionThreeIrrelevantItems_MOCK3",irrelevant:true}

        ])

        realCollectionFiveMixedItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionFiveMixedItems_MOCK1",irrelevant:true}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionFiveMixedItems_MOCK2"}
          {id:"MOCK3",cid:"MOCK3",matchVal:"realCollectionFiveMixedItems_MOCK3",irrelevant:true}
          {id:"MOCK4",cid:"MOCK4",matchVal:"realCollectionFiveMixedItems_MOCK4"}
          {id:"MOCK5",cid:"MOCK5",matchVal:"realCollectionFiveMixedItems_MOCK5",irrelevant:true}

        ])
        realCollectionTwoItems = new Backbone.Collection([
          {id:"MOCK1",cid:"MOCK1",matchVal:"realCollectionTwoItems_MOCK1"}
          {id:"MOCK2",cid:"MOCK2",matchVal:"realCollectionTwoItems_MOCK2"}

        ])
        realOtherCollection = new Backbone.Collection([
          {id:"MOCKOTHER1",cid:"MOCKOTHER1"}
        ])
      )
      test("watchingSingleCollectionSingleItem_createsItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollection])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 1)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollection_MOCK1")
      )
      test("watchingSingleCollectionFiveItems_createsFiveItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 5)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionFiveMixedItems_MOCK3")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionFiveMixedItems_MOCK5")
      )
      test("watchingSingleCollectionAllRelevantItems_createsAllItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionThreeItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 3)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionThreeItems_MOCK3")
      )
      test("watchingSingleCollectionAllIrrelevantItems_createsNoItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 0)
      )

      test("watchingSingleCollectionMixedItems_createsOnlyRelevantItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 2)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK4")
      )

      test("watchingMultpleCollectionsMixedItems_createsAllItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
        )
        chai.assert.equal(bvmc.length, 12)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK1")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollectionFiveMixedItems_MOCK3")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionFiveMixedItems_MOCK5")
        chai.assert.equal(bvmc.at(5).get("match"),"realCollection_MOCK1")
        chai.assert.equal(bvmc.at(6).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(7).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(8).get("match"),"realCollectionThreeItems_MOCK3")
        chai.assert.equal(bvmc.at(9).get("match"),"realCollectionThreeIrrelevantItems_MOCK1")
        chai.assert.equal(bvmc.at(10).get("match"),"realCollectionThreeIrrelevantItems_MOCK2")
        chai.assert.equal(bvmc.at(11).get("match"),"realCollectionThreeIrrelevantItems_MOCK3")
      )
      test("watchingMultpleCollectionsMixedItems_createsAllRelevantItems", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
          ,
          (wi)->
            match:wi.get("matchVal")
          ,
          (wi)->
            wi.get("irrelevant") isnt true
        )
        chai.assert.equal(bvmc.length, 6)
        chai.assert.equal(bvmc.at(0).get("match"),"realCollectionFiveMixedItems_MOCK2")
        chai.assert.equal(bvmc.at(1).get("match"),"realCollectionFiveMixedItems_MOCK4")
        chai.assert.equal(bvmc.at(2).get("match"),"realCollection_MOCK1")
        chai.assert.equal(bvmc.at(3).get("match"),"realCollectionThreeItems_MOCK1")
        chai.assert.equal(bvmc.at(4).get("match"),"realCollectionThreeItems_MOCK2")
        chai.assert.equal(bvmc.at(5).get("match"),"realCollectionThreeItems_MOCK3")
      )
      test("addingRelevantItem_addsItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollection.push({id:"MOCK2",cid:"MOCK2",matchVal:"realCollection_MOCK2"})
        bvmc.add=JsMockito.mockFunction()
        bvmc.remove=JsMockito.mockFunction()
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))

      )
      test("addingThreeRelevantItems_addsThreeItem", ()->
        bvmc = new ObservingViewModelCollection()
        bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        realCollection.push({id:"MOCK2",cid:"MOCK2",matchVal:"realCollection_MOCK2"})
        realCollection.push({id:"MOCK3",cid:"MOCK3",matchVal:"realCollection_MOCK3"})
        realCollection.push({id:"MOCK4",cid:"MOCK4",matchVal:"realCollection_MOCK4"})
        bvmc.add=JsMockito.mockFunction()
        bvmc.remove=JsMockito.mockFunction()
        bvmc.updateFromWatchedCollections(
          (i,wi)->
            i.get("match") is wi.get("matchVal")
        ,
        (wi)->
          match:wi.get("matchVal")
        ,
        (wi)->
          wi.get("irrelevant") isnt true
        )
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK2"))
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK3"))
        JsMockito.verify(bvmc.add)(JsHamcrest.Matchers.hasMember("match","realCollection_MOCK4"))
      )
      suite("No custom remover function set", ()->
        bvmc = undefined
        oadd = undefined
        oremove = undefined
        setup(()->
          bvmc = new ObservingViewModelCollection()
          bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          )
        )
        test("Removing relevant item removes item", ()->
          realCollectionFiveMixedItems.remove(realCollectionFiveMixedItems.at(1))
          oadd=bvmc.add
          oremove= bvmc.remove
          bvmc.add=JsMockito.mockFunction()
          JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
            oadd.call(bvmc,i)
          )
          bvmc.remove=JsMockito.mockFunction()
          JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
            oremove.call(bvmc,i)
          )
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          )
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))

        )
        test("Clearing watched collection - removes all relevant items", ()->
          realCollectionFiveMixedItems.reset()
          oadd=bvmc.add
          oremove= bvmc.remove
          bvmc.add=JsMockito.mockFunction()
          JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
            oadd.call(bvmc,i)
          )
          bvmc.remove=JsMockito.mockFunction()
          JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
            oremove.call(bvmc,i)
          )
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          )
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK4")))

        )
      )
      suite("onremove event set", ()->
        bvmc = undefined
        oadd = undefined
        oremove = undefined
        onremove = undefined
        setup(()->
          onremove = JsMockito.mockFunction()
          bvmc = new ObservingViewModelCollection()
          bvmc.watch([realCollectionFiveMixedItems,realCollection,realCollectionThreeItems,realCollectionThreeIrrelevantItems])
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          ,
            onremove
          )
        )
        test("Removing relevant item - removes from collection and calls onremove handler with item as parameter", ()->
          realCollectionFiveMixedItems.remove(realCollectionFiveMixedItems.at(1))
          oadd=bvmc.add
          oremove= bvmc.remove
          bvmc.add=JsMockito.mockFunction()
          JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
            oadd.call(bvmc,i)
          )
          bvmc.remove=JsMockito.mockFunction()
          JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
            oremove.call(bvmc,i)
          )
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          ,
            onremove
          )
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
          JsMockito.verify(onremove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
        )
        test("Clearing watched collection - calls remover function on all relevant items", ()->
          realCollectionFiveMixedItems.reset()
          oadd=bvmc.add
          oremove= bvmc.remove
          bvmc.add=JsMockito.mockFunction()
          JsMockito.when(bvmc.add)(JsHamcrest.Matchers.anything()).then((i)->
            oadd.call(bvmc,i)
          )
          bvmc.remove=JsMockito.mockFunction()
          JsMockito.when(bvmc.remove)(JsHamcrest.Matchers.anything()).then((i)->
            oremove.call(bvmc,i)
          )
          bvmc.updateFromWatchedCollections(
            (i,wi)->
              i.get("match") is wi.get("matchVal")
          ,
            (wi)->
              match:wi.get("matchVal")
          ,
            (wi)->
              wi.get("irrelevant") isnt true
          ,
            onremove
          )
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
          JsMockito.verify(bvmc.remove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK4")))
          JsMockito.verify(onremove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK2")))
          JsMockito.verify(onremove)(JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.hasMember("match","realCollectionFiveMixedItems_MOCK4")))

        )
      )

    )
  )


)

