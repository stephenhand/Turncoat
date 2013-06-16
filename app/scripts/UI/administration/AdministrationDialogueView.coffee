define(['underscore', 'backbone', "jquery"], (_, Backbone, $)->
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

