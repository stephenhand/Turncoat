define(['isolate!UI/administration/AdministrationDialogueView'], (AdministrationDialogueView)->
  suite("AdministrationDialogueView", ()->
    mocks = window.mockLibrary["UI/administration/AdministrationDialogueView"]
    suite("setActiveTab", ()->
      test("removesActiveClassFromAnyElementWithATabClass", ()->
        new AdministrationDialogueView().setActiveTab({})
        JsMockito.verify(mocks.jqueryObjects[".administration-tab"].toggleClass)("active-tab", false)
      )
    )
  )


)

