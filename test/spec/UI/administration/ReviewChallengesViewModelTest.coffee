define(['isolate!UI/administration/ReviewChallengesViewModel'], (ReviewChallengesViewModel)->
  suite("ReviewChallengesViewModel", ()->
    suite("initialize", ()->

      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        chai.assert.instanceOf(rcvm.challenges, Backbone.Collection)
      )
    )
  )


)

