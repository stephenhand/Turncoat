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
      @subViews.get("playAreaView")?.render()
      @subViews.get("administrationView").render()
      $("#administrationDialogue").jqm(onHide:()=>
        @model?.set("administrationDialogueActive" , false)
        true
      )
      @model.on("change:administrationDialogueActive",(m, val)=>
        if val then $("#administrationDialogue").jqmShow() else $("#administrationDialogue").jqmHide()
      )

    routeChanged:(route)->
      @subViews.get("playAreaView").routeChanged(route)
      if route.subRoutes?.administrationDialogue?
        @model.set("administrationDialogueActive", true)
        @subViews.get("administrationView").routeChanged(route.subRoutes.administrationDialogue)
      else
        @model.set("administrationDialogueActive", false)


    createModel:()->
      @model = new ManOWarTableTopViewModel(
        administrationDialogueActive:false
      )

    createPlayAreaView:(state)->
      @subViews.set("playAreaView", new PlayAreaView(
        gameState:state
      ))

    createAdministrationView:()->
      @subViews.set("administrationView", new AdministrationView(
        $el:$("#administrationDialogue")
      ))
  ManOWarTableTopView
)

