define(['underscore', 'backbone', "lib/turncoat/Factory", 'text!data/manOWarGameTemplates.txt'], (_, Backbone, Factory, templatesListText)->
  class LocalStoragePersister
    loadUser:(id)->
      if !id? then throw new Error("Must specify a player id.")
      return id

    loadGameTemplateList:(type, player)->

      new Backbone.Collection(
        for gameTemplate in JSON.parse(templatesListText)
          id:gameTemplate.id
          label:gameTemplate.label
          players:gameTemplate.players?.length

      )

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
  Factory.registerPersister("LocalStoragePersister",LocalStoragePersister)

  LocalStoragePersister
)

