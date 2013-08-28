mockModelInstance = null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/administration/ReviewChallengesViewModel","UI/administration/ReviewChallengesView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockModelInstance={}
        mockModelInstance
    )
  )
)

define(['isolate!UI/administration/ReviewChallengesView'], (ReviewChallengesView)->
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
  )


)

