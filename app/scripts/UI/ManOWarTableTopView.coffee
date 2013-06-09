define(['underscore', 'backbone', 'UI/BaseView', 'UI/PlayAreaView', 'text!templates/ManOWarTableTop.html'], (_, Backbone, BaseView, PlayAreaView, templateText)->
  class ManOWarTableTopView extends BaseView
    initialize: (options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#gameRoot"
      super(options)
      @playAreaView = new PlayAreaView(
        gameState:options.gameState

      )

    render:()->
      super()
      @playAreaView.render()

    createModel:()->
  ManOWarTableTopView
)

