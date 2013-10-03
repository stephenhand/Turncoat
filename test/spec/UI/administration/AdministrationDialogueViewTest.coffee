advModel = null

require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("UI/administration/AdministrationDialogueViewModel","UI/administration/AdministrationDialogueView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      advModel = {get:JsMockito.mockFunction()}
      ()->
        advModel


    )
  )
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
        setTab:JsMockito.mockFunction()
    )

  )
  Isolate.mapAsFactory("UI/administration/CreateGameView","UI/administration/AdministrationDialogueView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        render:JsMockito.mockFunction()
        setTab:JsMockito.mockFunction()
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
      setup(()->
        JsMockito.when(advModel.get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            if key is "tabs"
              new Backbone.Collection([
                name:"createGame"
              ,
                name:"reviewChallenges"
              ])
        )
      )
      test("modelHasCreateGameTab_setsTabOnCreateGameTabView", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.createGameView.setTab)(new JsHamcrest.SimpleMatcher(
          matches:(t)=>
            adv.model.get("tabs").at(0)
        ))
      )
      test("modelHasNoCreateGameTab_unsetsTabOnCreateGameTabView", ()->
        JsMockito.when(advModel.get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            if key is "tabs"
              new Backbone.Collection([
                name:"not createGame"
              ,
                name:"reviewChallenges"
              ])
        )
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.createGameView.setTab)(JsHamcrest.Matchers.nil())
      )
      test("modelHasReviewChallengesTab_setsTabOnReviewChallengesTabView", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.reviewChallengesView.setTab)(new JsHamcrest.SimpleMatcher(
          matches:(t)=>
            adv.model.get("tabs").at(1)
        ))
      )
      test("modelHasReviewChallengesTab_unsetsTabOnReviewChallengesTabView", ()->
        JsMockito.when(advModel.get)(JsHamcrest.Matchers.anything()).then(
          (key)->
            if key is "tabs"
              new Backbone.Collection([
                name:"createGame"
              ,
                name:"not reviewChallenges"
              ])
        )
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.reviewChallengesView.setTab)(JsHamcrest.Matchers.nil())
      )
      test("rendersCreateGameTab", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.createGameView.render)()
      )
      test("rendersReviewChallengesTab", ()->
        adv=new AdministrationDialogueView()
        adv.render()
        JsMockito.verify(adv.reviewChallengesView.render)()

      )
    )
  )


)

