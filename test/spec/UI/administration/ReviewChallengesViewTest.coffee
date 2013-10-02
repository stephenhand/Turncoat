mockModelInstance = null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/administration/ReviewChallengesViewModel","UI/administration/ReviewChallengesView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockModelInstance = selectChallenge:JsMockito.mockFunction()

    )
  )
)

define(["isolate!UI/administration/ReviewChallengesView"], (ReviewChallengesView)->
  mocks = window.mockLibrary["UI/administration/ReviewChallengesView"]
  suite("ReviewChallengesView", ()->
    suite("constructor", ()->
      test("setsRootSelectorIfNotSet", ()->
        rcv = new ReviewChallengesView()
        chai.assert.isString(rcv.rootSelector)
      )
      test("setsRootSelectorToOptionIfSet", ()->
        rcv = new ReviewChallengesView(rootSelector:"MOCK_ROOT_SELECTOR")
        chai.assert.equal(rcv.rootSelector, "MOCK_ROOT_SELECTOR")
      )
      test("setsTemplate", ()->
        rcv = new ReviewChallengesView()
        chai.assert.isString(rcv.template)
      )
    )
    suite("createModel", ()->
      test("createsModel", ()->
        rcv = new ReviewChallengesView()
        rcv.createModel()
        chai.assert.equal(rcv.model, mockModelInstance)
        chai.assert.isNotNull(rcv.model)
      )
    )
    suite("challengeListItem_clicked", ()->
      test("eventTargetIdPresent_callsModelsSelectChallengeWithEventCurrentTargetId", ()->
        rcv = new ReviewChallengesView()
        rcv.createModel()
        rcv.challengeListItem_clicked(
          currentTarget:
            id:"MOCK_TARGET_ID"
        )
        JsMockito.verify(rcv.model.selectChallenge)("MOCK_TARGET_ID")
      )
      test("eventTargetIdUndefined_callsModelsSelectChallengeWithNothing", ()->
        rcv = new ReviewChallengesView()
        rcv.createModel()
        rcv.challengeListItem_clicked(
          currentTarget:{}
        )
        JsMockito.verify(rcv.model.selectChallenge)(JsHamcrest.Matchers.nil())
      )
      test("eventTargetUndefined_throws", ()->
        rcv = new ReviewChallengesView()
        rcv.createModel()
        chai.assert.throws(()->
          rcv.challengeListItem_clicked({})
        )
      )
      test("eventUndefined_throws", ()->
        rcv = new ReviewChallengesView()
        rcv.createModel()
        chai.assert.throws(()->
          rcv.challengeListItem_clicked()
        )
      )
    )
  )


)

