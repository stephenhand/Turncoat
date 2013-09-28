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
      contextCaller =
        call:(func, param)->
          func(param)


      test("removesActiveClassFromAnyElementWithATabClass", ()->
        contextCaller.call(new AdministrationDialogueView().tabClicked, {currentTarget:{}})
        JsMockito.verify(mocks.jqueryObjects[".administration-tab"].toggleClass)("active-tab", false)
      )
      test("appliesActiveClassToCurrentContext", ()->
        event=
          currentTarget:{}
        new AdministrationDialogueView().tabClicked(event)
        JsMockito.verify(mocks.jqueryObjects[event.currentTarget].parent)()
        JsMockito.verify(mocks.jqueryObjects.methodResults.parent.toggleClass)("active-tab", true)

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

