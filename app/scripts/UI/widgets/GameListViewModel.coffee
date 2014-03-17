define(["setTimeout","underscore", "backbone", "lib/turncoat/Constants", "UI/component/ObservingViewModelCollection", "UI/component/ObservableOrderCollection", "AppState"], (setTimeout, _, Backbone, Constants, ObservingViewModelCollection, ObservableOrderCollection, AppState)->
  GetStatusText = (userStatus)->
    switch userStatus
      when Constants.READY_STATE
        "Waiting on other players to respond to the challenge."
      when Constants.CHALLENGED_STATE
        "A challenge awaiting your response."

  class GameListViewModel extends ObservingViewModelCollection
    initialize:(m, opts)->
      super()
      _.extend(@, ObservableOrderCollection)
      @setOrderAttribute("ordinal")
      @comparator=(a, b)->
        switch
          when !a.get("created")?.unix? && !b.get("created")?.unix? then 0
          when !a.get("created")?.unix? then 1
          when !b.get("created")?.unix? then -1
          when a.get("created").unix() > b.get("created").unix() then -1
          when a.get("created").unix() < b.get("created").unix() then 1
          else 0

      @watch([AppState.get("currentUser").get("games")])
      @listenTo(AppState, "change::currentUser", ()->
        @unwatch()
        @watch([AppState.get("currentUser").get("games")])
      ,@)
      @onSourceUpdated=()->
        @updateFromWatchedCollections(
          (item, watched)->
            item.get("id")? and (item.get("id") is watched.get("id"))
        ,
          (input)->
            newItem = new Backbone.Model(
              created:input.get("created")
              createdText:input.get("created")?.format?('MMMM Do YYYY, h:mm:ss a') ? "--"
              id:input.get("id")
              label:input.get("label")
              statusText: GetStatusText(input.get("userStatus"))
              new:true
            )
            setTimeout(()->
              newItem.unset("new")
            )
            newItem
        ,
          opts?.filter ? ()->true
        )

      @onSourceUpdated()


    selectGame:(id)->
      set = false
      for challenge in @models
        if challenge.get("id") is id
          set = true
          if !challenge.get("selected")
            challenge.set("selected", true)
            @trigger("selectedGameChanged", id)
        else
          challenge.unset("selected")
      if !set then @trigger("selectedGameChanged")

  GameListViewModel
)


