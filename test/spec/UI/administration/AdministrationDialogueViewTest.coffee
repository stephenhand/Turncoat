define(['isolate!UI/administration/AdministrationDialogueView'], (AdministrationDialogueView)->
  suite("AdministrationDialogueView", ()->
    mocks = window.mockLibrary["UI/administration/AdministrationDialogueView"]
    suite("tabClicked", ()->
      contextCaller =
        call:(func)->
          func()


      test("removesActiveClassFromAnyElementWithATabClass", ()->
        contextCaller.call(new AdministrationDialogueView().tabClicked)
        JsMockito.verify(mocks.jqueryObjects[".administration-tab"].toggleClass)("active-tab", false)
      )
      test("appliesActiveClassToCurrentContext", ()->
        contextCaller.call(new AdministrationDialogueView().tabClicked)
        JsMockito.verify(mocks.jqueryObjects[contextCaller].parent)()
        JsMockito.verify(mocks.jqueryObjects.methodResults.parent.toggleClass)("active-tab", true)

      )
    )
  )


)

