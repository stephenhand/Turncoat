define(['jquery','underscore', 'backbone', 'jqModal', 'UI/BaseView', 'UI/PlayAreaView', 'UI/ManOWarTableTopViewModel', 'text!templates/ManOWarTableTop.html'],
($, _, Backbone, modal, BaseView, PlayAreaView, ManOWarTableTopViewModel, templateText)->
  class ManOWarTableTopView extends BaseView
    initialize: (options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#gameRoot"
      super(options)
      if (options.gameState)
        @createPlayAreaView(options.gameState)

    render:()->
      super()
      @playAreaView.render()
      $("#administrationDialogue").jqm()


    createModel:()->
      @model = new ManOWarTableTopViewModel(
        administrationDialogueActive:false
      )

    createPlayAreaView:(state)->
      @playAreaView = new PlayAreaView(
        gameState:state
      )

  ManOWarTableTopView
)

