define(['underscore', 'backbone'], (_, Backbone)->
  class LocalStoragePersister
    loadGameList:(type)->
      if !window.localStorage["current-games"]
        return null
      for game in JSON.parse(window.localStorage["current-games"]) when !type? or game._type is type
        new Backbone.Model(
          name:game.name
          id:game.id
          type:game._type
        )

    retrieveGameState:(id)->
      if (!id?) then throw new Error("Must specify a game id to retrieve it from storage")
      if !window.localStorage["current-games"]
        return null
      found = null
      for game in JSON.parse(window.localStorage["current-games"]) when game.id is id
        found = game
        break
      found

    loadInviteList:(filter)->
      if !window.localStorage["current-invites"]
        return null
      for invite in JSON.parse(window.localStorage["current-invites"]) when !filter? or ((!filter.type? or invite.type is filter.type) and (!filter.status? or invite.status is filter.status))
        invite.time = new Date(invite.time)
        new Backbone.Model(
          invite
        )
  LocalStoragePersister
)

