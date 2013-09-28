define(["underscore", "backbone"], (_, Backbone)->
  AdministrationDialogueViewModel = Backbone.Model.extend(
    initialize: (options)->
      @tabs = new Backbone.Collection([
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
      ])

  )
)


