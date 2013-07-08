define(['underscore', 'backbone', 'UI/BaseView', 'UI/PlayAreaView', 'jqModal', 'UI/ManOWarTableTopViewModel', 'text!templates/ManOWarTableTop.html'], (_, Backbone, BaseView, PlayAreaView, modal, ManOWarTableTopViewModel, templateText)->
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

