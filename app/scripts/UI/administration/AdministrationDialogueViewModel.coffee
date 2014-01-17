define(["underscore", "backbone", "AppState"], (_, Backbone, AppState)->
  AdministrationDialogueViewModel = Backbone.Model.extend(
    initialize: (options)->
      @set("tabs",new Backbone.Collection([
        name:"createGame"
        class:"create-game-tab"
        label:"Create New Game"
        active:true
        visible:true
      ,
        name:"currentGames"
        class:"current-games-tab"
        label:"Current Games"
        active:false
        visible:true
      ,
        name:"reviewChallenges"
        class:"challenges-tab"
        label:"Challenges"
        active:false
        visible:true
      ]))

    setActiveTab:(name)->
      if (name? and @get("tabs").findWhere(name:name))
        tab.set("active",tab.get("name") is name) for tab in @get("tabs").models

    getDefaultTab:()->
      switch
        when !AppState.get("currentUser")? or !AppState.get("currentUser").get("games")? then @get("tabs").findWhere(name:"createGame")
        when AppState.get("currentUser").get("games").findWhere(userStatus:"PLAYING")? then @get("tabs").findWhere(name:"currentGames")
        when AppState.get("currentUser").get("games").length then @get("tabs").findWhere(name:"reviewChallenges")
        else  @get("tabs").findWhere(name:"createGame")
  )
)


