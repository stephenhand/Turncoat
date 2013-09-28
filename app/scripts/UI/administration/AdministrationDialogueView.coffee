define(['underscore', 'backbone', "jquery", "UI/BaseView", "UI/administration/AdministrationDialogueViewModel", "UI/administration/CreateGameView", "UI/administration/ReviewChallengesView", "text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, AdministrationDialogueViewModel, CreateGameView,ReviewChallengesView, templateText)->
  setActiveTab=(tabElement)->
    $(".administration-tab").toggleClass("active-tab",false)
    $(tabElement).parent().toggleClass("active-tab",true)

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
      setActiveTab(event.currentTarget)

    createModel:()->
       @model = new AdministrationDialogueViewModel()

    render:()->
      super()
      @createGameView.render()
      @reviewChallengesView.render()

    createCreateGameTabView:()->
      @createGameView = new CreateGameView($("#createGame"))

    createChallengesTabView:()->
      @reviewChallengesView = new ReviewChallengesView($("#reviewChallenges"))


  AdministrationDialogueView
)

