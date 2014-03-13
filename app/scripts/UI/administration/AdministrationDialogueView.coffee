define(['underscore', 'backbone', "jquery", "UI/routing/Router", "UI/component/BaseView", "UI/administration/AdministrationDialogueViewModel", "UI/administration/CreateGameView", "UI/administration/CurrentGamesView", "UI/administration/ReviewChallengesView", "text!templates/AdministrationDialogue.html"],
  (_, Backbone, $, Router, BaseView, AdministrationDialogueViewModel, CreateGameView, CurrentGamesView, ReviewChallengesView, templateText)->
    class AdministrationDialogueView extends BaseView
      initialize:(options)->
        options ?={}
        options.template = templateText
        options.rootSelector = "#administrationDialogue"
        super(options)
        @createCreateGameTabView()
        @createChallengesTabView()
        @createCurrentGamesTabView()
      events:
        "click .tab-header" : "tabClicked"

      tabClicked:(event)->
        if (!event? || !event.currentTarget?)
          throw new Error("tabClicked called with invalid event")
        Router.setSubRoute("administrationDialogue", $("div.tab-content",$(event.currentTarget).parent()).attr("id"))

      createModel:()->
        @model = new AdministrationDialogueViewModel()

      routeChanged:(route)->
        tab = route?.parts?.shift()
        if (tab?)
          if tab is "default"
            route.parts.unshift(@model.getDefaultTab().get("name"))
            Router.setSubRoute("administrationDialogue",route.toString(), replace:true)
          else
            @model.setActiveTab(tab)
            @subViews.get(tab+"View").routeChanged(route)

      render:()->
        super()
        @subViews.get("createGameView").setTab(@model.get("tabs").findWhere(name:"createGame"))
        @subViews.get("currentGamesView").setTab(@model.get("tabs").findWhere(name:"currentGames"))
        @subViews.get("reviewChallengesView").setTab(@model.get("tabs").findWhere(name:"reviewChallenges"))
        @subViews.get("createGameView").render()
        @subViews.get("currentGamesView").render()
        @subViews.get("reviewChallengesView").render()

      createCreateGameTabView:()->
        @subViews.set("createGameView", new CreateGameView($("#createGame")))
      createCurrentGamesTabView:()->
        @subViews.set("currentGamesView", new CurrentGamesView($("#currentGames")))

      createChallengesTabView:()->
        @subViews.set("reviewChallengesView", new ReviewChallengesView($("#reviewChallenges")))


    AdministrationDialogueView
)

