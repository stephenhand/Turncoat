define(['rivets','lib/turncoat/Game', 'lib/turncoat/Factory', 'UI/ManOWarTableTopView', 'text!data/testInitialState.txt', 'text!data/config.txt'], (rivets, Game, Factory, ManOWarTableTopView, testInitialState, configText)->
    window.App =
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
              if (obj instanceof Backbone.Collection) then obj["models"] else obj.get(keypath)
            publish: (obj, keypath, value)->
              obj.set(keypath, value)
        )
        rivets.formatters.rotateCss=(cssVal)->
          "rotate("+cssVal+"deg)"
        rivets.binders.style_top=(el,value)->
          el.style.top=value
        rivets.binders.style_left=(el,value)->
          el.style.left=value
        rivets.binders.style_transform=(el,value)->
          el.style.transform=value
          el.style.msTransform=value
          el.style.webkitTransform=value


    config = JSON.parse(configText)
    Factory.setDefaultMarshaller(config.defaultMarshaller)

    window.App

)