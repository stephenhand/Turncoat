define(["underscore", "backbone", "jquery","uuid", "lib/concurrency/Mutex"], (_, Backbone, $, UUID, Mutex)->
  MESSAGE_QUEUE = "message_queue"

  enqueueMessage = (recipient, gameId, payload)->

  dequeueMessage = (userId, gameId)->
    id = userId
    if gameId? then id+="::"+gameId
    Mutex.lock("LOCAL_TRANSPORT_MESSAGE_QUEUE"+id,()->
      json = window.localStorage.getItem(MESSAGE_QUEUE+"::"+id)


    )


  class LocalStorageTransport
    constructor:(@userId, @gameId)->

    startListening:()->
      handler = (event)=>
        keyParts = event.originalEvent.key.split("::")
        switch keyParts[0]
          when MESSAGE_QUEUE
            if keyParts[1] is @userId and (@gameId is keyParts[2] or (!@gameId? and !keyParts[2]?))
              dequeueMessage(@userId, @gameId)
      $(window).on("storage", handler)
      start = @startListening
      @startListening = ()->
      @stopListening = ()->
        $(window).off("storage", handler)
        @stopListening = ()->
        @startListening = start


    stopListening:()->


  LocalStorageTransport
)

