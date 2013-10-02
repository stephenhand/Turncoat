define(['underscore', 'backbone', 'UI/BaseView', 'UI/administration/ReviewChallengesViewModel',"text!templates/ReviewChallenges.html"], (_, Backbone, BaseView, ReviewChallengesViewModel, templateText)->
  class ReviewChallengesView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#reviewChallenges"
      super(options)

    createModel:()->
      @model = new ReviewChallengesViewModel()
    events:
      'click .list-item':'challengeListItem_clicked'

    challengeListItem_clicked:(event)->
      @model.selectChallenge(event.currentTarget.id)

  ReviewChallengesView
)

