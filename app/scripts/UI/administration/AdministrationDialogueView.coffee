define(['underscore', 'backbone', "jquery", "UI/BaseView", "UI/administration/AdministrationDialogueViewModel", "UI/administration/CreateGameView", "text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, AdministrationDialogueViewModel, CreateGameView, templateText)->
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

    events:
      "click .tab-header" : "tabClicked"

    tabClicked:(event)->
      setActiveTab(event.currentTarget)

    createModel:()->
       @model = new AdministrationDialogueViewModel()

    render:()->
      super()
      @createGameView.render()

    createCreateGameTabView:()->
      @createGameView = new CreateGameView($("#createGame"))
  AdministrationDialogueView
)

