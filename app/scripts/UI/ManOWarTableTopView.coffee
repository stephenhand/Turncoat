define(['setTimeout','jquery', 'underscore', 'backbone', 'jqModal', "UI/routing/Router", 'UI/component/BaseView', 'UI/PlayAreaView', 'UI/administration/AdministrationDialogueView', 'UI/ManOWarTableTopViewModel', 'text!templates/ManOWarTableTop.html'],(setTimeout, $, _, Backbone, modal, Router, BaseView, PlayAreaView, AdministrationView, ManOWarTableTopViewModel, templateText)->
  class ManOWarTableTopView extends BaseView
    initialize: (options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#gameRoot"
      super(options)
      @createPlayAreaView()
      @createAdministrationView()

    render:()->
      super()
      @subViews.get("playAreaView").render()
      @subViews.get("administrationDialogue").render()
      $("#administrationDialogue").jqm(onHide:()=>
        Router.unsetSubRoute("administrationDialogue")
        true
      )
      @model.on("change:administrationDialogueActive",(m, val)=>
        if val then $("#administrationDialogue").jqmShow() else $("#administrationDialogue").jqmHide()
      )

    routeChanged:(route)->
      @subViews.get("playAreaView").routeChanged(route)
      if route.subRoutes?.administrationDialogue?
        @model.set("administrationDialogueActive", true)
        @subViews.get("administrationDialogue").routeChanged(route.subRoutes.administrationDialogue)
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
      @subViews.set("administrationDialogue", new AdministrationView(
        $el:$("#administrationDialogue")
      ))
  ManOWarTableTopView
)

