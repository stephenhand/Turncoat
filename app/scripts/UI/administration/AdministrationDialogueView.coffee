define(['underscore', 'backbone', "jquery", "UI/BaseView","text!templates/AdministrationDialogue.html"], (_, Backbone, $, BaseView, templateText)->
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

  AdministrationDialogueView
)

