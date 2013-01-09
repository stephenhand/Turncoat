define(['rivets','lib/Game'], (rivets, Game)->
    App =
        start:()->
            @game = new Game()
            @game.loadState({})
        render:()->
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
    App

)