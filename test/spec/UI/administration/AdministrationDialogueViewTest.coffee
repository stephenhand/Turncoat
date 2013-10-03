require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("UI/administration/BaseView","UI/administration/AdministrationDialogueView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        render:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("UI/administration/ReviewChallengesView","UI/administration/AdministrationDialogueView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        render:JsMockito.mockFunction()
    )

  )
  Isolate.mapAsFactory("UI/administration/CreateGameView","UI/administration/AdministrationDialogueView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        render:JsMockito.mockFunction()
    )
  )
)

define(['isolate!UI/administration/AdministrationDialogueView'], (AdministrationDialogueView)->
  suite("AdministrationDialogueView", ()->
    mocks = window.mockLibrary["UI/administration/AdministrationDialogueView"]
    suite("tabClicked", ()->
      adv = null
      setup(()->
        adv=new AdministrationDialogueView()
        adv.model = setActiveTab:JsMockito.mockFunction()
      )



      test("ValidInputEvent_CallsModelSetActiveTabWithEventCurrentTargetAssociatedTabContentPaneId", ()->
        event = {currentTarget:{id:"AN ID"}}
        adv.tabClicked(event)
        JsMockito.verify(mocks.jqueryObjects[event.currentTarget].parent)()
        JsMockito.verify(mocks.jqueryObjects["div.tab-content"][mocks.jqueryObjects.methodResults.parent].attr)("id")
        JsMockito.verify(adv.model.setActiveTab)("id::VALUE")
      )
      test("InvalidInputEvent_Throws", ()->
        chai.assert.throw(()->adv.tabClicked({}))
      )
    )
    suite("render", ()->
      test("rendersCreateGameTab", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.createGameView.render)()
      )
      test("appliesActiveClassToCurrentContext", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.reviewChallengesView.render)()

      )
    )
  )


)

