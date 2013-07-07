define(['underscore', 'backbone', 'UI/BaseView', 'UI/PlayAreaView', 'jqModal', 'text!templates/ManOWarTableTop.html'], (_, Backbone, BaseView, PlayAreaView, modal, templateText)->
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

    createPlayAreaView:(state)->
      @playAreaView = new PlayAreaView(
        gameState:state
      )

  ManOWarTableTopView
)

