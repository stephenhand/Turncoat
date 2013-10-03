define(["isolate!UI/administration/AdministrationDialogueViewModel"], (AdministrationDialogueViewModel)->
  suite("AdministrationDialogueViewModel", ()->
    suite("setActiveTab", ()->
      advm = null
      setup(()->
        advm = new AdministrationDialogueViewModel()
      )
      test("InputIsNameOfTab_SetsTabWithNameToActive", ()->
        advm.setActiveTab("reviewChallenges")
        chai.assert(advm.get("tabs").findWhere(name:"reviewChallenges").get("active"))
      )
      test("InputIsNameOfTab_SetsOtherTabsToNotActive", ()->
        tab.set("active", true) for tab in advm.get("tabs").models
        advm.setActiveTab("reviewChallenges")
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"createGame").get("active"))
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"currentGames").get("active"))
      )

      test("InputIsNotNameOfTab_DoesNothing", ()->
        advm.get("tabs").findWhere(name:"createGame").set("active", true)
        advm.setActiveTab("NOT A TAB")
        chai.assert(advm.get("tabs").findWhere(name:"createGame").get("active"))
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"currentGames").get("active"))
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"reviewChallenges").get("active"))
      )

      test("NoInput_DoesNothing", ()->
        advm.get("tabs").findWhere(name:"createGame").set("active", true)
        advm.setActiveTab()
        chai.assert(advm.get("tabs").findWhere(name:"createGame").get("active"))
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"currentGames").get("active"))
        chai.assert.isFalse(advm.get("tabs").findWhere(name:"reviewChallenges").get("active"))
      )
    )
  )


)

