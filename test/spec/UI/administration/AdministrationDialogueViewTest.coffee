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
  )


)

