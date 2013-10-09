define(["isolate!UI/component/ObservableOrderCollection", "underscore", "backbone"], (ObservableOrderCollection, _, Backbone)->
  suite("ObservableOrderCollection", ()->
    ooc = null
    setup(()->
      ooc = new Backbone.Collection([
        a:9
      ,
        b:1
      ,
        c:5
      ])
      _.extend(ooc, ObservableOrderCollection)
      ooc.on = JsMockito.mockFunction()
      ooc.off = JsMockito.mockFunction()
    )
    suite("setOrderAttribute", ()->
      test("PopulatedModels_SetsAttributeOfSpecifiedNameToOrdinalNumber", ()->
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        chai.assert.equal(0, ooc.at(0).get("ORDER_ATTRIBUTE"))
        chai.assert.equal(1, ooc.at(1).get("ORDER_ATTRIBUTE"))
        chai.assert.equal(2, ooc.at(2).get("ORDER_ATTRIBUTE"))

      )
      test("bindsAddRemoveResetToSameHandler", ()->
        setHandlers = []
        JsMockito.when(ooc.on)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
          (name, handler)->
            setHandlers[name]=handler
        )
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        JsMockito.verify(ooc.on)("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on)("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on)("reset", JsHamcrest.Matchers.func())
        chai.assert.equal(setHandlers["add"],setHandlers["remove"])
        chai.assert.equal(setHandlers["add"],setHandlers["reset"])
      )
      test("repeatedCalls_bindsAddRemoveResetOnlyOnce", ()->
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        JsMockito.verify(ooc.on, JsMockito.Verifiers.once())("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on, JsMockito.Verifiers.once())("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on, JsMockito.Verifiers.once())("reset", JsHamcrest.Matchers.func())
      )
      suite("Collection Update Handler", ()->
        test("CollectionHasModelsAttributeSpecified_SetsAttributeOfSpecifiedNameToOrdinalNumber", ()->
          ooc.setOrderAttribute("ORDER_ATTRIBUTE")
          #unset ordering set up initially
          for mod in ooc.models
            mod.unset("ORDER_ATTRIBUTE")
          JsMockito.verify(ooc.on)("add", new JsHamcrest.SimpleMatcher(
            matches:(h)->
              h()
              ooc.at(0).get("ORDER_ATTRIBUTE") is 0 &&
              ooc.at(1).get("ORDER_ATTRIBUTE") is 1 &&
              ooc.at(2).get("ORDER_ATTRIBUTE") is 2
          ))
        )
        test("CollectionHasModelsAttributeNotSpecified_Throws", ()->
          chai.assert.throw(()->ooc.setOrderAttribute())
        )
        test("CollectionHasNoModelsProperty_Throws", ()->
          ooc.models = undefined
          chai.assert.throw(()->ooc.setOrderAttribute("ORDER_ATTRIBUTE"))
        )
      )
    )
    suite("unsetOrderAttribute", ()->
      test("PopulatedModels_SetsAttributeOfSpecifiedNameToOrdinalNumber", ()->
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        chai.assert.isUndefined(ooc.at(0).get("ORDER_ATTRIBUTE"))
        chai.assert.isUndefined(ooc.at(1).get("ORDER_ATTRIBUTE"))
        chai.assert.isUndefined(ooc.at(2).get("ORDER_ATTRIBUTE"))

      )
      test("unbindsAddRemoveResetHandlersSetWhenBound", ()->
        setHandlers = []
        JsMockito.when(ooc.on)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
          (name, handler)->
            setHandlers[name]=handler
        )
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        JsMockito.verify(ooc.off)("add", setHandlers["add"])
        JsMockito.verify(ooc.off)("remove", setHandlers["remove"])
        JsMockito.verify(ooc.off)("reset", setHandlers["reset"])
      )
      test("LeavesOtherHandlersBound", ()->
        called = 0
        _.extend(ooc, Backbone.Events)
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.on("add", ()->called++)
        ooc.on("remove", ()->called++)
        ooc.on("reset", ()->called++)
        ooc.unsetOrderAttribute()
        ooc.trigger("add")
        ooc.trigger("remove")
        ooc.trigger("reset")
        chai.assert.equal(3, called)
      )
      test("RepeatedUnbinds_OnlyUnbindsOnce", ()->
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        JsMockito.verify(ooc.off, JsMockito.Verifiers.once())("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.once())("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.once())("reset", JsHamcrest.Matchers.func())
      )
      test("CalledBeforeSetOrderAttribute_DoesNothing", ()->
        ooc.unsetOrderAttribute()
        JsMockito.verify(ooc.off, JsMockito.Verifiers.never())("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.never())("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.never())("reset", JsHamcrest.Matchers.func())
      )
      test("MultipleSetsAndUnset_OnlyBindsAndUnbindsWhenStateToggles", ()->

        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.setOrderAttribute("ORDER_ATTRIBUTE")
        ooc.unsetOrderAttribute()
        ooc.unsetOrderAttribute()
        JsMockito.verify(ooc.on, JsMockito.Verifiers.times(3))("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on, JsMockito.Verifiers.times(3))("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.on, JsMockito.Verifiers.times(3))("reset", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.times(3))("add", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.times(3))("remove", JsHamcrest.Matchers.func())
        JsMockito.verify(ooc.off, JsMockito.Verifiers.times(3))("reset", JsHamcrest.Matchers.func())
      )
    )
  )


)

