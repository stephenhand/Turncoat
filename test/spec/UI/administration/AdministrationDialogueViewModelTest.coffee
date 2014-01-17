require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState", 'UI/administration/AdministrationDialogueViewModel', (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->

    )
  )
)

define(["isolate!UI/administration/AdministrationDialogueViewModel"], (AdministrationDialogueViewModel)->
  suite("AdministrationDialogueViewModel", ()->
    mocks = window.mockLibrary["UI/administration/AdministrationDialogueViewModel"]
    advm = null
    setup(()->
      advm = new AdministrationDialogueViewModel()
    )
    suite("setActiveTab", ()->
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
    suite("getDefaultTab", ()->
      test("AppState currentUser not set - returns createGame Tab", ()->
        mocks["AppState"].get = (key)->
        chai.assert.equal(advm.getDefaultTab().get("name"), "createGame")
      )
      suite("AppState currentUser is set", ()->
        test("AppState games has entries with userStatus of PLAYING - returns currentGames Tab", ()->
          mocks["AppState"].get = (key)->
            switch key
              when "currentUser"
                new Backbone.Model(
                  games:new Backbone.Collection([
                    userStatus:"NOT_PLAYING"
                  ,
                    userStatus:"PLAYING"
                  ,
                    userStatus:"NOT_PLAYING"
                  ])
                )
          chai.assert.equal(advm.getDefaultTab().get("name"), "currentGames")
        )
        test("AppState games has entries but none with userStatus of PLAYING - returns reviewChallenges Tab", ()->
          mocks["AppState"].get = (key)->
            switch key
              when "currentUser"
                new Backbone.Model(
                  games:new Backbone.Collection([
                      userStatus:"NOT_PLAYING"
                    ,
                      userStatus:"NOT_PLAYING"
                    ,
                      userStatus:"NOT_PLAYING"
                    ])
                )
          chai.assert.equal(advm.getDefaultTab().get("name"), "reviewChallenges")
        )
        test("AppState games empty - returns createGame Tab", ()->
          mocks["AppState"].get = (key)->
            switch key
              when "currentUser"
                new Backbone.Model(games:new Backbone.Collection([]))
          chai.assert.equal(advm.getDefaultTab().get("name"), "createGame")
        )
        test("AppState games not set - returns createGame Tab", ()->
          mocks["AppState"].get = (key)->
            switch key
              when "currentUser"
                new Backbone.Model()
          chai.assert.equal(advm.getDefaultTab().get("name"), "createGame")
        )
      )
    )
  )


)

