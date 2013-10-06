define(['jquery', 'underscore', 'backbone', 'jqModal', 'UI/component/BaseView', 'UI/PlayAreaView', 'UI/administration/AdministrationDialogueView', 'UI/ManOWarTableTopViewModel', 'text!templates/ManOWarTableTop.html'],($, _, Backbone, modal, BaseView, PlayAreaView, AdministrationView, ManOWarTableTopViewModel, templateText)->
  class ManOWarTableTopView extends BaseView
    initialize: (options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#gameRoot"
      super(options)
      if (options.gameState)
        @createPlayAreaView(options.gameState)
      @createAdministrationView()

    render:()->
      super()
      @playAreaView?.render()
      @administrationView.render()
      $("#administrationDialogue").jqm()
      @model.on("change:administrationDialogueActive",(m, val)=>
        if val then $("#administrationDialogue").jqmShow() else $("#administrationDialogue").jqmHide()
      )


    createModel:()->
      @model = new ManOWarTableTopViewModel(
        administrationDialogueActive:false
      )

    createPlayAreaView:(state)->
      @playAreaView = new PlayAreaView(
        gameState:state
      )

    createAdministrationView:()->
      @administrationView= new AdministrationView(
        $el:$("#administrationDialogue")
      )
  ManOWarTableTopView
)

