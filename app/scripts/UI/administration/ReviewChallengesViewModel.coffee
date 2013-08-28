define(['underscore', 'backbone', 'UI/BaseViewModelCollection'], (_, Backbone, BaseViewModelCollection)->
  ReviewChallengesViewModel = Backbone.Model.extend(
    initialize:()->
      @challenges=new BaseViewModelCollection()
  )


  ReviewChallengesViewModel
)

