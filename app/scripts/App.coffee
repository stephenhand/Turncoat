define(['rivets','lib/turncoat/Game', 'lib/turncoat/Factory', 'UI/ManOWarTableTopView', 'text!data/testInitialState.txt', 'text!data/config.txt'], (rivets, Game, Factory, ManOWarTableTopView, testInitialState, configText)->
    App =
        createGame:()->
            @game = new Game()
            @game.loadState(testInitialState)

        render:()->
            @rootView = new ManOWarTableTopView(gameState:@game.state)
            @rootView.render()

        configureRivets:()->
            rivets.configure(
                prefix:"rv"
                adapter:
                    subscribe:(obj,keypath,callback)->
                        obj.on('change:' + keypath, callback)
                    unsubscribe:(obj,keypath,callback)->
                        obj.off('change:' + keypath, callback)
                    read:(obj,keypath)->
                        obj.get(keypath)
                    publish: (obj, keypath, value)->
                        obj.set(keypath, value)
            )
    config = JSON.parse(configText)
    Factory.setDefaultMarshaller(config.defaultMarshaller)
    App

)