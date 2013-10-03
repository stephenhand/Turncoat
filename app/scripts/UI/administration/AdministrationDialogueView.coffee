define(['underscore', 'backbone', "jquery", "UI/BaseView", "UI/administration/AdministrationDialogueViewModel", "UI/administration/CreateGameView", "UI/administration/ReviewChallengesView", "text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, AdministrationDialogueViewModel, CreateGameView,ReviewChallengesView, templateText)->
  class AdministrationDialogueView extends BaseView
    initialize:(options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#administrationDialogue"
      super(options)
      @createCreateGameTabView()
      @createChallengesTabView()

    events:
      "click .tab-header" : "tabClicked"

    tabClicked:(event)->
      if (!event? || !event.currentTarget?)
        throw new Error("tabClicked called with invalid event")
      @model.setActiveTab($("div.tab-content",$(event.currentTarget).parent()).attr("id"))

    createModel:()->
      @model = new AdministrationDialogueViewModel()

    render:()->
      super()
      @createGameView.setTab(@model.get("tabs").findWhere(name:"createGame"))
      @reviewChallengesView.setTab(@model.get("tabs").findWhere(name:"reviewChallenges"))
      @createGameView.render()
      @reviewChallengesView.render()

    createCreateGameTabView:()->
      @createGameView = new CreateGameView($("#createGame"))

    createChallengesTabView:()->
      @reviewChallengesView = new ReviewChallengesView($("#reviewChallenges"))


  AdministrationDialogueView
)

