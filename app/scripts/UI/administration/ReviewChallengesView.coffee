define(['underscore', 'backbone', 'UI/component/BaseView', 'UI/administration/ReviewChallengesViewModel',"text!templates/ReviewChallenges.html"], (_, Backbone, BaseView, ReviewChallengesViewModel, templateText)->
  class ReviewChallengesView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#reviewChallenges"
      super(options)

    setTab:(@tabModel)->

    createModel:()->
      @model = new ReviewChallengesViewModel(tab:@tabModel)
    events:
      'click .left-panel .list-item':'challengeListItem_clicked'
      'click .issue-challenge':'issueChallenge_clicked'

    challengeListItem_clicked:(event)->
      @model.selectChallenge(event.currentTarget.id)

    issueChallenge_clicked:(event)->
      @model.issueChallenge(event.currentTarget.id)

  ReviewChallengesView
)

