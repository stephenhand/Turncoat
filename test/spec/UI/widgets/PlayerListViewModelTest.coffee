require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/widgets/PlayerListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:()->
          @on=JsMockito.mockFunction()
          @ovmcWatch = JsMockito.mockFunction()
          @ovmcUnwatch = JsMockito.mockFunction()
        watch : ()->
          @ovmcWatch.apply(@,arguments)
        unwatch : ()->
          @ovmcUnwatch.apply(@,arguments)
        updateFromWatchedCollections : ()->
      )
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelItem","UI/widgets/PlayerListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Model.extend(
        initialize:()->
          @watch=JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("AppState","UI/widgets/PlayerListViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      loadGame:()->
    )
  )
)

define(["isolate!UI/widgets/PlayerListViewModel", "jsMockito", "jsHamcrest", "chai"], (PlayerListViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/widgets/PlayerListViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("PlayerListViewModel", ()->
    plvm = null
    game = null
    setup(()->

      plvm = new PlayerListViewModel()
      game = new Backbone.Model(
        label:"GAME FROM ID: "+a
        players:new Backbone.Collection([
          id:"SELECTED_PLAYER"
          name:"SELECTED_PLAYER_NAME"
        ,
          id:"NOT_SELECTED_PLAYER"
          name:"NOT_SELECTED_PLAYER_NAME"

        ])
        users:new Backbone.Collection([
          id:"MOCK_USER"
          playerId:"SELECTED_PLAYER"
          status:"MOCK_USER_STATUS"
        ,
          id:"OTHER_USER"
          playerId:"NOT_SELECTED_PLAYER"
          status:"OTHER_USER_STATUS"

        ])
      )
    )
    suite("watch", ()->
      setup(()->
        plvm.updateFromWatchedCollections = jm.mockFunction()
      )
      test("Calls updateFromWatchedCollection", ()->
        plvm.watch(game)
        jm.verify(plvm.updateFromWatchedCollections)(m.func(), m.func())
      )
      test("Calls watch of superclass with game's player list", ()->
        plvm.watch(game)
        jm.verify(plvm.ovmcWatch)(m.equivalentArray([game.get("players")]))
      )
      test("Game had undefined users collection - throws", ()->
        a.throw(()->
          plvm.watch(new Backbone.Model(
            label:"T"
            players:new Backbone.Collection([
              id:"A"
              name:"B"
            ,
              id:"C"
              name:"D"

            ])
          ))
        )
      )
      suite("OnSourceUpdated handler", ()->
        setup(()->
          plvm.updateFromWatchedCollections = jm.mockFunction()
          plvm.watch(game)
          plvm.updateFromWatchedCollections = jm.mockFunction()
        )
        test("Calls updateFromWatchedCollection", ()->
          plvm.onSourceUpdated()
          jm.verify(plvm.updateFromWatchedCollections)(m.func(), m.func())
        )
        test("Calls updateFromWatchedCollection with same handlers as when watch first called", ()->
          a1 = null
          c1 = null
          a2 = null
          c2 = null
          plvm = new PlayerListViewModel()
          plvm.updateFromWatchedCollections = jm.mockFunction()
          jm.when(plvm.updateFromWatchedCollections)().then((c, a)->
            c1 = c
            a1 = a
          )
          plvm.watch(game)
          plvm.updateFromWatchedCollections = jm.mockFunction()
          jm.when(plvm.updateFromWatchedCollections)().then((c, a)->
            c2 = c
            a2 = a
          )
          plvm.onSourceUpdated()
          a.equal(a1.toString(),a2.toString())
          a.equal(c1.toString(),c2.toString())
        )
        suite(null, ()->
          setup(()->
            plvm.trigger = jm.mockFunction()
            plvm.push(
              id:"SELECTED_PLAYER"
              name:"SELECTED_PLAYER_NAME"
              user:new Backbone.Model(
                id:"NOT_MOCK_USER"
                status:"MOCK_USER_STATUS"
              )
            )
            plvm.push(
              id:"NOT_SELECTED_PLAYER"
              name:"NOT_SELECTED_PLAYER_NAME"
              user:new Backbone.Model(
                id:"OTHER_USER"
                status:"OTHER_USER_STATUS"
              )
            )
            mocks['AppState'].get = jm.mockFunction()
            jm.when(mocks['AppState'].get)("currentUser").then(()->
              new Backbone.Model(
                id:"MOCK_USER"
              )
            )
          )
          suite("currentUserStatusUpdate event logic", ()->
            test("Contains player with user matching current user - triggers currentUserStatusUpdate with user id", ()->
              plvm.first().get("user").set("id","MOCK_USER")
              plvm.onSourceUpdated()
              jm.verify(plvm.trigger)("currentUserStatusUpdate", "MOCK_USER_STATUS")
            )
            test("Multiple calls with same player matching current user - triggers event per call to onSouurceUpdated", ()->
              plvm.first().get("user").set("id","MOCK_USER")
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              jm.verify(plvm.trigger, v.times(4))("currentUserStatusUpdate", "MOCK_USER_STATUS")
            )
            test("Contains no players with user matching current user - triggers currentUserStatusUpdate with no value", ()->

              plvm.onSourceUpdated()
              jm.verify(plvm.trigger)("currentUserStatusUpdate")
              jm.verify(plvm.trigger, v.never())("currentUserStatusUpdate", m.anything())
            )
            test("Multiple calls with no player matching current user - triggers event per call to onSouurceUpdated", ()->
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              plvm.onSourceUpdated()
              jm.verify(plvm.trigger, v.times(4))("currentUserStatusUpdate")
              jm.verify(plvm.trigger, v.never())("currentUserStatusUpdate", m.anything())
            )
          )
          suite("selectedForUser proprty logic", ()->

            test("Player with matching user id - sets selected for user only on player with User Id matching current user", ()->
              plvm.first().get("user").set("id","MOCK_USER")
              plvm.onSourceUpdated()
              a(plvm.at(0).get("selectedForUser"))
              a.isUndefined(plvm.at(1).get("selectedForUser"))

            )
            test("Valid identifier but no player with current user id - doesnt set selectedForUser on anything", ()->
              plvm.onSourceUpdated()
              a.isUndefined(plvm.findWhere(selectedForUser:true))

            )
          )
        )
        suite("updateFromWatchedCollection comparer", ()->
          comparer = undefined;
          setup(()->
            jm.when(plvm.updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a)->
              comparer = c
            )
            plvm.onSourceUpdated()
          )
          test("Matches when ids match", ()->
            a(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model(id:"MATCHING_ID")))
          )
          test("No match when ids don't match", ()->
            a.isFalse(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model(id:"NOT MATCHING_ID")))
          )
          test("No match when one id is missing", ()->
            a.isFalse(comparer(new Backbone.Model(id:"MATCHING_ID"),new Backbone.Model()))
          )
          test("No match when both ids are missing", ()->
            a.isFalse(comparer(new Backbone.Model(),new Backbone.Model()))
          )
        )
        suite("updateFromWatchedCollection adder", ()->
          adder = undefined
          addedSourceUser = undefined
          addedSource = undefined
          setup(()->
            addedSourceUser = new Backbone.Model(
              id:"ADDED USER ID"
              status:"ADDED USER STATUS"
              playerId:"ADDED ID"
              watch:jm.mockFunction()
              unwatch:jm.mockFunction()
            )
            addedSource = new Backbone.Model(
              id:"ADDED ID"
              name:"ADDED NAME"
              description:"ADDED DESCRIPTION"
            )
            jm.when(plvm.updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a)->
              adder = a
            )
            game.get("users").push(addedSourceUser)
            plvm.onSourceUpdated()
          )
          test("Copies id, description and name from input model and user status and id from located user.", ()->
            added = adder(new Backbone.Model(
              id:"ADDED ID"
              name:"ADDED NAME"
              description:"ADDED DESCRIPTION"
            ))
            a.equal(added.get("id"),"ADDED ID")
            a.equal(added.get("name"),"ADDED NAME")
            a.equal(added.get("user").get("id"),"ADDED USER ID")
            a.equal(added.get("user").get("status"),"ADDED USER STATUS")
            a.equal(added.get("description"),"ADDED DESCRIPTION")
          )
          test("Id not in selectedChallenge user collection - leaves user unset", ()->
            added = adder(new Backbone.Model(
              id:"ADDED USERLESS ID"
              name:"ADDED NAME"
              description:"ADDED DESCRIPTION"
            ))
            a.isUndefined(added.get("user"))
          )
          test("Ignores additional attributes on player or user", ()->
            added = adder(new Backbone.Model(
              id:"ADDED ID"
              name:"ADDED NAME"
              prop1:"SOMETHING"
              user:new Backbone.Model(
                id:"ADDED USER"
                status:"SOME STATUS"
                prop1:"SOMETHING"
              )
              description:"ADDED DESCRIPTION"
            ))
            a.isUndefined(added.get("prop1"))
            a.isUndefined(added.get("user").get("prop1"))
          )
          test("Watches added item's name and description, user's status attributes", ()->
            added = adder(addedSource)
            jm.verify(added.watch)(
              m.hasItem(
                m.allOf(
                  m.hasMember("model", addedSource)
                ,
                  m.hasMember(
                    "attributes"
                  ,
                    m.equivalentArray([
                      "name",
                      "description"
                    ])
                  )
                )
              )
            )
          )
          test("User attribute watches matched user from challenge", ()->
            added = adder(addedSource)
            jm.verify(added.get("user").watch)(
              m.hasItem(
                m.allOf(
                  m.hasMember("model", addedSourceUser)
                ,
                  m.hasMember(
                    "attributes"
                  ,
                    m.equivalentArray([
                      "id"
                      "status"
                    ])
                  )
                )
              )
            )
          )
          suite("OnModelUpdated for watched items", ()->
            added = undefined
            modelUpdated = undefined
            userModelUpdated = undefined
            origInit = null
            setup(()->
              origInit = mocks["UI/component/ObservingViewModelItem"].prototype.initialize
              mocks["UI/component/ObservingViewModelItem"].prototype.initialize =
                ()->
                  @watch=jm.mockFunction()
                  @unwatch=jm.mockFunction()
                  jm.when(@watch)(m.hasItem(m.hasMember("model", addedSource))).then((d)->
                    modelUpdated=@onModelUpdated
                  )
                  jm.when(@watch)(m.hasItem(m.hasMember("model", addedSourceUser))).then((d)->
                    userModelUpdated=@onModelUpdated
                  )

              added = adder(addedSource)
            )
            teardown(()->
              mocks["UI/component/ObservingViewModelItem"].prototype.initialize = origInit
            )
            suite("Player attributes other than user modified", ()->
              test("Sets name & description attributes on item", ()->
                addedSource.set(
                  name:"NEW NAME"
                  description: "NEW DESCRIPTION"
                )
                modelUpdated(addedSource)
                a.equal(added.get("name"), "NEW NAME")
                a.equal(added.get("description"), "NEW DESCRIPTION")

              )
              test("Leaves other player attributes unmodified", ()->
                addedSource.set(
                  id:"NEW ID"
                  name:"NEW NAME"
                  description: "NEW DESCRIPTION"
                )
                modelUpdated(addedSource)
                a.equal(added.get("id"), "ADDED ID")

              )
            )
            suite("User attributes modified", ()->
              test("Sets id & status attributes provided from user on user", ()->
                addedSourceUser.set(
                  status:"NEW STATUS"
                )
                userModelUpdated(addedSourceUser)
                a.equal(added.get("user").get("status"), "NEW STATUS")

              )
              test("Unsets these attributes if not present on new model", ()->
                addedSourceUser.unset("status")
                userModelUpdated(addedSourceUser)
                a.isUndefined(added.get("user").get("status"))

              )
              test("Leaves other existing attributes on user unmodified", ()->
                added.get("user").set("propA", "A")
                addedSourceUser.set(
                  status:"NEW STATUS"
                )
                userModelUpdated(addedSourceUser)
                a.equal(added.get("user").get("propA"), "A")

              )
            )

          )
        )
        suite("updateFromWatchedCollection - onremove", ()->
          removed = undefined
          remover = undefined
          setup(()->
            removed = new Backbone.Model()
            removed.watch=jm.mockFunction()
            removed.unwatch=jm.mockFunction()
            plvm.updateFromWatchedCollections = jm.mockFunction()
            jm.when(plvm.updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a, f, r)->
              remover = r
            )
            plvm.onSourceUpdated()
          )
          test("Unwatches removed item", ()->
            remover(removed)
            jm.verify(removed.unwatch)()
          )
          test("Has user - Unwatches user as well", ()->
            user = new Backbone.Model()
            user.watch=jm.mockFunction()
            user.unwatch=jm.mockFunction()
            removed.set("user", user)
            remover(removed)
            jm.verify(user.unwatch)()
          )
        )
      )
      suite("Selected challenge user collection", ()->

        test("New challenge has users - challengePlayerList listens to user collection's add, remove and reset methods using same handler", ()->
          handler = null
          plvm.listenTo = jm.mockFunction()
          jm.when(plvm.listenTo)(
            m.anything(),
            m.anything(),
            m.anything(),
            m.anything()
          ).then((a,b,h, d)->
            handler = h
          )
          plvm.watch(game)
          jm.verify(plvm.listenTo)(game.get("users"), "add", handler, plvm)
          jm.verify(plvm.listenTo)(game.get("users"), "remove", handler, plvm)
          jm.verify(plvm.listenTo)(game.get("users"), "reset", handler, plvm)
        )
        suite("Update handlers", ()->
          handler = null
          origInit = null
          setup(()->
            origInit = mocks["UI/component/ObservingViewModelItem"].prototype.initialize
            mocks["UI/component/ObservingViewModelItem"].prototype.initialize =
              ()->
                @watch=jm.mockFunction()
                @unwatch=jm.mockFunction()

            plvm.push(
              id:"SELECTED_PLAYER"
              name:"SELECTED_PLAYER_NAME"
              user:new Backbone.Model(
                id:"MOCK_USER"
                status:"MOCK_USER_STATUS"
              )
            )
            plvm.last().watch = jm.mockFunction()
            plvm.last().unwatch = jm.mockFunction()
            plvm.last().get("user").watch = jm.mockFunction()
            plvm.last().get("user").unwatch = jm.mockFunction()
            plvm.push(
              id:"NOT_SELECTED_PLAYER"
              name:"NOT_SELECTED_PLAYER_NAME"
              user:new Backbone.Model(
                id:"OTHER_USER"
                status:"OTHER_USER_STATUS"
              )
            )
            plvm.last().watch = jm.mockFunction()
            plvm.last().unwatch = jm.mockFunction()
            plvm.last().get("user").watch = jm.mockFunction()
            plvm.last().get("user").unwatch = jm.mockFunction()
            plvm.push(
              id:"USERLESS_PLAYER"
              name:"USERLESS_PLAYER_NAME"
            )
            plvm.last().watch = jm.mockFunction()
            plvm.last().unwatch = jm.mockFunction()
            plvm.listenTo = jm.mockFunction()
            jm.when(plvm.listenTo)(
              m.anything(),
              m.anything(),
              m.anything(),
              m.anything()
            ).then((a,b,h,d)->
              handler = h
            )
            plvm.watch(game)
          )
          teardown(()->
            mocks["UI/component/ObservingViewModelItem"].prototype.initialize = origInit
          )

          test("User mapped to player changes id to invalid - removes user from player, unwatches user, leaving others in place.", ()->
            oldUser = plvm.get("SELECTED_PLAYER").get("user")
            game.get("users").reset([
              id:"MOCK_USER"
              playerId:"NOT A PLAYER ID"
              status:"MOCK_USER_STATUS"
            ,
              id:"OTHER_USER"
              playerId:"NOT_SELECTED_PLAYER"
              status:"OTHER_USER_STATUS"

            ])
            handler()
            jm.verify(oldUser.unwatch)()
            a.isUndefined(plvm.get("SELECTED_PLAYER").get("user"))
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
            a.isUndefined(plvm.get("USERLESS_PLAYER").get("user"))
          )
          test("User mapped to player changes removed - removes user from player, unwatches user, leaving others in place.", ()->
            oldUser = plvm.get("SELECTED_PLAYER").get("user")
            game.get("users").reset([
              id:"OTHER_USER"
              playerId:"NOT_SELECTED_PLAYER"
              status:"OTHER_USER_STATUS"

            ])
            handler()
            a.isUndefined(plvm.get("SELECTED_PLAYER").get("user"))
            jm.verify(oldUser.unwatch)()
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
            a.isUndefined(plvm.get("USERLESS_PLAYER").get("user"))
          )
          test("New user added mapped to player that currently has no user - maps new user to player and watches user", ()->
            game.get("users").reset([
              id:"MOCK_USER"
              playerId:"SELECTED_PLAYER"
              status:"MOCK_USER_STATUS"
            ,
              id:"OTHER_USER"
              playerId:"NOT_SELECTED_PLAYER"
              status:"OTHER_USER_STATUS"
            ,
              id:"USERLESS_USER"
              playerId:"USERLESS_PLAYER"
              status:"USERLESS_STATUS"

            ])
            handler()
            a.equal(plvm.get("SELECTED_PLAYER").get("user").id,"MOCK_USER")
            a.equal(plvm.get("SELECTED_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
            a.equal(plvm.get("USERLESS_PLAYER").get("user").id,"USERLESS_USER")
            a.equal(plvm.get("USERLESS_PLAYER").get("user").get("status"),"USERLESS_STATUS")
            jm.verify(plvm.get("USERLESS_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",game.get("users").last())))
          )
          test("Users remapped to different players - unwatches all, reassigns, then watches again", ()->
            oldUser1 = plvm.get("SELECTED_PLAYER").get("user")
            oldUser2 = plvm.get("NOT_SELECTED_PLAYER").get("user")
            game.get("users").reset([
              id:"MOCK_USER"
              playerId:"USERLESS_PLAYER"
              status:"MOCK_USER_STATUS"
            ,
              id:"OTHER_USER"
              playerId: "SELECTED_PLAYER"
              status:"OTHER_USER_STATUS"
            ,
              id:"USERLESS_USER"
              playerId:"NOT_SELECTED_PLAYER"
              status:"USERLESS_STATUS"

            ])
            handler()
            jm.verify(oldUser1.unwatch)()
            jm.verify(oldUser2.unwatch)()
            a.equal(plvm.get("USERLESS_PLAYER").get("user").id,"MOCK_USER")
            a.equal(plvm.get("USERLESS_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
            a.equal(plvm.get("SELECTED_PLAYER").get("user").id,"OTHER_USER")
            a.equal(plvm.get("SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").id,"USERLESS_USER")
            a.equal(plvm.get("NOT_SELECTED_PLAYER").get("user").get("status"),"USERLESS_STATUS")
            jm.verify(plvm.get("USERLESS_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",game.get("users").first())))
            jm.verify(plvm.get("SELECTED_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",game.get("users").at(1))))
            jm.verify(plvm.get("NOT_SELECTED_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",game.get("users").last())))
          )
          test("Multiple users mapped to same player - throws", ()->
            game.get("users").reset([
              id:"MOCK_USER"
              playerId:"USERLESS_PLAYER"
              status:"MOCK_USER_STATUS"
            ,
              id:"OTHER_USER"
              playerId: "USERLESS_PLAYER"
              status:"OTHER_USER_STATUS"
            ,
              id:"USERLESS_USER"
              playerId:"USERLESS_PLAYER"
              status:"USERLESS_STATUS"

            ])
            a.throw(()->handler())
          )
        )
      )
    )
    suite("unwatch", ()->
      setup(()->
        plvm.stopListening = jm.mockFunction()
      )
      test("Calls superclass unwatch with 'true'", ()->
        plvm.watch( new Backbone.Model(
          label:"T"
          players:new Backbone.Collection([
            id:"A"
            name:"B"
          ,
            id:"C"
            name:"D"

          ])
          users:new Backbone.Collection([])
        ))
        plvm.unwatch()
        jm.verify(plvm.ovmcUnwatch)(true)
      )
      test("Stops listening to users", ()->
        oldUsers =  new Backbone.Model()
        plvm.watch(new Backbone.Model(
          label:"T"
          players:new Backbone.Collection([
            id:"A"
            name:"B"
          ,
            id:"C"
            name:"D"

          ])
          users:oldUsers
        ))
        plvm.unwatch()
        jm.verify(plvm.stopListening)(oldUsers)
      )
    )
  )


)

