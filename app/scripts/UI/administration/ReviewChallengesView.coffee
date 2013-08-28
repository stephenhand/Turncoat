define(['underscore', 'backbone', 'UI/BaseView', 'UI/administration/ReviewChallengesViewModel',"text!templates/createGame.html"], (_, Backbone, BaseView, ReviewChallengesViewModel, templateText)->
  class ReviewChallengesView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#reviewChallenges"
      super(options)

    createModel:()->
      @model = new ReviewChallengesViewModel()

  ReviewChallengesView
)

