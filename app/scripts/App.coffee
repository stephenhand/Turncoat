define(['lib/Game'], (Game)->
    App =
        start:()->
            @game = new Game()
            @game.loadState({})
    App

)