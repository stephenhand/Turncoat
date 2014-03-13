require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("setTimeout","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
    )

  )
  Isolate.mapAsFactory("UI/component/ObservableOrderCollection","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      setOrderAttribute:JsMockito.mockFunction()
    )

  )
  Isolate.mapAsFactory("AppState","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      loadGame:()->
    )

  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockBaseViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        mockConstructedBVMC.unwatch = JsMockito.mockFunction()
        mockConstructedBVMC.updateFromWatchedCollections = JsMockito.mockFunction()
        mockConstructedBVMC
      mockBaseViewModelCollection
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelItem","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Model.extend(
        initialize:()->
          @watch=JsMockito.mockFunction()
      )
    )
  )
  Isolate.mapAsFactory("UI/widgets/GameListViewModel","UI/administration/ReviewChallengesViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Collection.extend(
        initialize:()->
          @selectGame=JsMockito.mockFunction()
      )
    )
  )

)

define(["isolate!UI/administration/ReviewChallengesViewModel", "jsMockito", "jsHamcrest", "chai"], (ReviewChallengesViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/ReviewChallengesViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ReviewChallengesViewModel", ()->
    setup(()->
      mocks["UI/component/ObservingViewModelItem"].watch = jm.mockFunction()
      mocks["UI/component/ObservingViewModelItem"].unwatch = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].prototype.selectChallenge = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].watch = jm.mockFunction()
      mocks["UI/widgets/GameListViewModel"].unwatch = jm.mockFunction()
    )
    suite("initialize", ()->
      mockGameList = new Backbone.Collection([])
      setup(()->
        mocks['AppState'].on = jm.mockFunction()
        mocks['AppState'].get = jm.mockFunction()
        mocks['AppState'].issueChallenge = jm.mockFunction()
        mocks['AppState'].acceptChallenge = jm.mockFunction()
        mocks["UI/component/ObservableOrderCollection"].setOrderAttribute = jm.mockFunction()
        jm.when(mocks['AppState'].get)(m.anything()).then(
          (key)->
            switch key
              when "currentUser"
                new Backbone.Model(
                  id:"MOCK_USER"
                  games:mockGameList
                )
              else undefined
        )
      )
      test("creates empty challengePlayerList", ()->
        rcvm = new ReviewChallengesViewModel()
        a.instanceOf(rcvm.get("challengePlayerList"), Backbone.Collection)
        a.equal(rcvm.get("challengePlayerList").length, 0)

      )

      test("createsChallenges", ()->
        rcvm = new ReviewChallengesViewModel()
        a.instanceOf(rcvm.get("challenges"), Backbone.Collection)
      )

      test("Has Tab attribute - binds Tab ActiveChanged", ()->
        rcvm = new ReviewChallengesViewModel(
          tab:
            on:jm.mockFunction()
        )
        jm.verify(rcvm.get("tab").on)("change:active", m.func())
      )
      suite("tabActiveHandler", ()->
        rcvm = null
        mockGet = jm.mockFunction()
        mockOn = jm.mockFunction()
        handler = null
        setup(()->
          jm.when(mockOn)("change:active", m.func()).then((e, h)->handler = h)
          rcvm = new ReviewChallengesViewModel(
            tab:
              on:mockOn
              get:mockGet
          )
        )
        test("Tab becomes active - does nothing", ()->
          jm.when(mockGet)("active").then(()->true)
          handler(rcvm.get("tab"))
          jm.verify(rcvm.get("challenges").selectGame, v.never())()
        )
        test("Tab becomes inactive - unselects challenge", ()->
          jm.when(mockGet)("active").then(()->false)
          handler(rcvm.get("tab"))
          jm.verify(rcvm.get("challenges").selectGame)()
        )

        suite("Challenges selectedChallengeChanged Handler", ()->
          rcvm = undefined
          setup(()->
            mocks["AppState"].loadGame = jm.mockFunction()
            jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->
              new Backbone.Model(
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
            rcvm = new ReviewChallengesViewModel()
            rcvm.set("selectedChallenge", get:()->)
          )
          suite("Valid Identifier", ()->
            setup(()->
            )
            test("Loads Game State Using Identifier", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(mocks["AppState"].loadGame)("AN IDENTIFIER")
            )
            test("Sets selectedChallenge attribute to result", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              a.equal("GAME FROM ID: AN IDENTIFIER", rcvm.get("selectedChallenge").get("label"))
            )
            test("Unsets selectedChallenge attribute if result undefined", ()->
              jm.when(mocks["AppState"].loadGame)(m.anything()).then((a)->)
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              a.isUndefined(rcvm.get("selectedChallenge"))
            )
            test("challengePlayerList unwatches", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").unwatch)(true)
            )
            test("challengePlayerList watches player list for challenge", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").watch)(m.equivalentArray([rcvm.get("selectedChallenge").get("players")]))

            )
            test("Calls updateFromWatchedCollection", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(m.func(), m.func())
            )
          )
          suite("No identifier", ()->
            test("Unsets SelectedChallenge", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged")
              a.isUndefined(rcvm.get("selectedChallenge"))
            )
            test("challengePlayerList unwatches", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged")
              jm.verify(rcvm.get("challengePlayerList").unwatch)(true)
            )
            test("mockWatchDataDupAttribute doesn't watch anything", ()->
              rcvm.get("challenges").trigger("selectedChallengeChanged")
              jm.verify(rcvm.get("challengePlayerList").watch, v.never())(m.anything())
            )
          )
          suite("OnSourceUpdated handler for challengePlayerList", ()->
            setup(()->
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
            )
            test("Calls updateFromWatchedCollection", ()->
              rcvm.get("challengePlayerList").updateFromWatchedCollections = jm.mockFunction()
              rcvm.get("challengePlayerList").onSourceUpdated()
              jm.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(m.func(), m.func())
            )
            test("Calls updateFromWatchedCollection with same handlers as when selectedChallengeChangeds first fired", ()->

              comparer = undefined
              adder = undefined
              jm.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)().then((c, a)->
                comparer = c
                adder = a
              )
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              rcvm.get("challengePlayerList").updateFromWatchedCollections = jm.mockFunction()
              rcvm.get("challengePlayerList").onSourceUpdated()
              jm.verify(rcvm.get("challengePlayerList").updateFromWatchedCollections)(
                new h.SimpleMatcher(
                  matches:(cc)->
                    cc.toString() is comparer.toString()
                ),
                new h.SimpleMatcher(
                  matches:(aa)->
                    aa.toString() is adder.toString()
                )
              )
            )
            test("Contains player with user matching current user - sets selectedChallengeUserStatus to that user status", ()->
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              a.equal("MOCK_USER_STATUS", rcvm.get("selectedChallengeUserStatus"))
            )
            test("Contains no players with user matching current user - unsets selectedChallengeUserStatus", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"NOT_MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              a.isUndefined(rcvm.get("selectedChallengeUserStatus"))
            )
            test("Player with matching user id - sets selected for user only on player with User Id matching current user", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              a(rcvm.get("challengePlayerList").at(0).get("selectedForUser"))
              a.isUndefined(rcvm.get("challengePlayerList").at(1).get("selectedForUser"))

            )
            test("validIdentifierNoPlayerWithCurrentUserId_doesntSetSelectedForUserOnAnything", ()->
              rcvm.set("selectedChallengeUserStatus", "SOMETHING")
              rcvm.get("challengePlayerList").push(
                id:"SELECTED_PLAYER"
                name:"SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"NOT_MOCK_USER"
                  status:"MOCK_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").push(
                id:"NOT_SELECTED_PLAYER"
                name:"NOT_SELECTED_PLAYER_NAME"
                user:new Backbone.Model(
                  id:"OTHER_USER"
                  status:"OTHER_USER_STATUS"
                )
              )
              rcvm.get("challengePlayerList").onSourceUpdated()
              a.isUndefined(rcvm.get("challengePlayerList").findWhere(selectedForUser:true))

            )
            suite("updateFromWatchedCollection comparer", ()->
              comparer = undefined;
              setup(()->
                jm.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a)->
                  comparer = c
                )
                rcvm.get("challengePlayerList").onSourceUpdated()
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
                jm.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a)->
                  adder = a
                )
                rcvm.get("selectedChallenge").get("users").push(addedSourceUser)
                rcvm.get("challengePlayerList").onSourceUpdated()
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
                rcvm.get("challengePlayerList").updateFromWatchedCollections = jm.mockFunction()
                jm.when(rcvm.get("challengePlayerList").updateFromWatchedCollections)(m.func(), m.func(), m.nil(), m.func()).then((c, a, f, r)->
                  remover = r
                )
                rcvm.get("challengePlayerList").onSourceUpdated()
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
            setup(()->
              rcvm.get("challengePlayerList").stopListening = jm.mockFunction()
            )
            test("Challenge already selected but that challenge had no users - challengePlayerList stops listening to nothing", ()->
              rcvm.set("selectedChallenge", new Backbone.Model(
                label:"T"
                players:new Backbone.Collection([
                  id:"A"
                  name:"B"
                ,
                  id:"C"
                  name:"D"

                ])
              ))
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").stopListening, v.never())(m.anything())
            )
            test("Challenge already selected and that challenge has users - challengePlayerList stops listening to those users", ()->
              oldUsers =  new Backbone.Model()
              rcvm.set("selectedChallenge", new Backbone.Model(
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
              cl = rcvm.get("challengePlayerList")
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(cl.stopListening)(oldUsers)
            )
            test("New challenge has users - challengePlayerList listens to user collection's add, remove and reset methods using same handler", ()->
              handler = null
              rcvm.get("challengePlayerList").listenTo = jm.mockFunction()
              jm.when(rcvm.get("challengePlayerList").listenTo)(
                m.anything(),
                m.anything(),
                m.anything(),
                m.anything()
              ).then((a,b,h, d)->
                handler = h
              )
              rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              jm.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "add", handler, rcvm)
              jm.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "remove", handler, rcvm)
              jm.verify(rcvm.get("challengePlayerList").listenTo)(rcvm.get("selectedChallenge").get("users"), "reset", handler, rcvm)
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

                rcvm.get("challengePlayerList").push(
                  id:"SELECTED_PLAYER"
                  name:"SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"MOCK_USER"
                    status:"MOCK_USER_STATUS"
                  )
                )
                rcvm.get("challengePlayerList").last().watch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").watch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").unwatch = jm.mockFunction()
                rcvm.get("challengePlayerList").push(
                  id:"NOT_SELECTED_PLAYER"
                  name:"NOT_SELECTED_PLAYER_NAME"
                  user:new Backbone.Model(
                    id:"OTHER_USER"
                    status:"OTHER_USER_STATUS"
                  )
                )
                rcvm.get("challengePlayerList").last().watch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").watch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().get("user").unwatch = jm.mockFunction()
                rcvm.get("challengePlayerList").push(
                  id:"USERLESS_PLAYER"
                  name:"USERLESS_PLAYER_NAME"
                )
                rcvm.get("challengePlayerList").last().watch = jm.mockFunction()
                rcvm.get("challengePlayerList").last().unwatch = jm.mockFunction()
                rcvm.get("challengePlayerList").listenTo = jm.mockFunction()
                jm.when(rcvm.get("challengePlayerList").listenTo)(
                  m.anything(),
                  m.anything(),
                  m.anything(),
                  m.anything()
                ).then((a,b,h, d)->
                  handler = h
                )
                rcvm.get("challenges").trigger("selectedChallengeChanged", "AN IDENTIFIER")
              )
              teardown(()->
                mocks["UI/component/ObservingViewModelItem"].prototype.initialize = origInit
              )

              test("User mapped to player changes id to invalid - removes user from player, unwatches user, leaving others in place.", ()->
                oldUser = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
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
                a.isUndefined(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user"))
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                a.isUndefined(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user"))
              )
              test("User mapped to player changes removed - removes user from player, unwatches user, leaving others in place.", ()->
                oldUser = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
                  id:"OTHER_USER"
                  playerId:"NOT_SELECTED_PLAYER"
                  status:"OTHER_USER_STATUS"

                ])
                handler()
                a.isUndefined(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user"))
                jm.verify(oldUser.unwatch)()
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                a.isUndefined(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user"))
              )
              test("New user added mapped to player that currently has no user - maps new user to player and watches user", ()->
                rcvm.get("selectedChallenge").get("users").reset([
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
                a.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").id,"MOCK_USER")
                a.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"OTHER_USER")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                a.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").id,"USERLESS_USER")
                a.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").get("status"),"USERLESS_STATUS")
                jm.verify(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",rcvm.get("selectedChallenge").get("users").last())))
              )
              test("Users remapped to different players - unwatches all, reassigns, then watches again", ()->

                oldUser1 = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                oldUser2 = rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
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
                a.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").id,"MOCK_USER")
                a.equal(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").get("status"),"MOCK_USER_STATUS")
                a.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").id,"OTHER_USER")
                a.equal(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").get("status"),"OTHER_USER_STATUS")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").id,"USERLESS_USER")
                a.equal(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").get("status"),"USERLESS_STATUS")
                jm.verify(rcvm.get("challengePlayerList").get("USERLESS_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",rcvm.get("selectedChallenge").get("users").first())))
                jm.verify(rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",rcvm.get("selectedChallenge").get("users").at(1))))
                jm.verify(rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user").watch)(m.hasItem(m.hasMember("model",rcvm.get("selectedChallenge").get("users").last())))
              )
              test("Multiple users mapped to same player - throws", ()->

                oldUser1 = rcvm.get("challengePlayerList").get("SELECTED_PLAYER").get("user")
                oldUser2 = rcvm.get("challengePlayerList").get("NOT_SELECTED_PLAYER").get("user")
                rcvm.get("selectedChallenge").get("users").reset([
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
      )
      suite("selectChallenge", ()->
        rcvm = null
        setup(()-> rcvm=new ReviewChallengesViewModel())
        test("Calls selectGame on challenges gameList", ()->
          rcvm.selectChallenge("A GAME ID")
          jm.verify(rcvm.get("challenges").selectGame)("A GAME ID")
        )
        test("Challenges not set - throws", ()->
          rcvm.unset("challenges")
          a.throw(()->rcvm.selectGame("A GAME ID"))
        )
      )
      suite("issueChallenge", ()->
        rcvm = null
        setup(()->
          rcvm = new ReviewChallengesViewModel()
        )
        test("Valid identifier and challenge selected - calls AppState issueChallenge with identifier and selected game", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          rcvm.issueChallenge("ANOTHER USER")
          jm.verify(mocks.AppState.issueChallenge)("ANOTHER USER", "SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.issueChallenge("ANOTHER USER")
          jm.verify(mocks.AppState.issueChallenge)("ANOTHER USER", m.nil())
        )
        test("No identifier - throws", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          a.throw(()->rcvm.issueChallenge())
        )
      )
      suite("acceptChallenge", ()->
        rcvm = null
        setup(()->
          rcvm = new ReviewChallengesViewModel()
        )
        test("Valid identifier and challenge selected - calls AppState issueChallenge with identifier and selected game", ()->
          rcvm.set("selectedChallenge", "SOMETHING")
          rcvm.acceptChallenge()
          jm.verify(mocks.AppState.acceptChallenge)("SOMETHING")
        )
        test("Valid identifier and no challenge selected - calls AppState issueChallenge with no game", ()->
          rcvm.unset("selectedChallenge")
          rcvm.acceptChallenge()
          jm.verify(mocks.AppState.acceptChallenge)(m.nil())
        )
      )
    )
  )


)

