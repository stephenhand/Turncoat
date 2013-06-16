define(['underscore', 'backbone', "jquery", "UI/BaseView","text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, templateText)->
  class AdministrationDialogueView extends BaseView
    initialize:(options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#administrationDialogue"
      super(options)

    events:
      "click .tab-header" : "setActiveTab"

    setActiveTab:()->
      $(".administration-tab").toggleClass("active-tab",false)
      $(this).parent().toggleClass("active-tab",true)

  AdministrationDialogueView
)

