define(['underscore', 'backbone', "jquery", "UI/BaseView", "UI/administration/AdministrationDialogueViewModel", "text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, AdministrationDialogueViewModel, templateText)->
  setActiveTab=(tabElement)->
    $(".administration-tab").toggleClass("active-tab",false)
    $(tabElement).parent().toggleClass("active-tab",true)

  class AdministrationDialogueView extends BaseView
    initialize:(options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#administrationDialogue"
      super(options)

    events:
      "click .tab-header" : "tabClicked"

    tabClicked:()=>
      setActiveTab(this)

    createModel:()->
       @model = new AdministrationDialogueViewModel()

  AdministrationDialogueView
)

