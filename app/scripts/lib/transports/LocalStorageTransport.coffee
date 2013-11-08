define(["underscore", "backbone", "jquery","uuid", "lib/concurrency/Mutex", "lib/turncoat/Factory"], (_, Backbone, $, UUID, Mutex, Factory)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_RECEIVED_MESSAGE_TYPE = "challenge-received"

  enqueueMessage = (recipient, gameId, payload)->

  dequeueMessage = (transport, userId, gameId)->
    id = userId
    if gameId? then id+="::"+gameId
    messageId = null
    transport
    Mutex.lock(
      key:"LOCAL_TRANSPORT_MESSAGE_QUEUE::"+id
      criticalSection:()->
        json = window.localStorage.getItem(MESSAGE_QUEUE+"::"+id)
        queue = JSON.parse(json)
        messageId = queue.shift()
        window.localStorage.setItem(MESSAGE_QUEUE+"::"+id, JSON.stringify(queue))
      success:()->
        envelopeJSON = window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)
        if (envelopeJSON)
          envelope = JSON.parse(envelopeJSON)
          switch envelope.type
            when CHALLENGE_RECEIVED_MESSAGE_TYPE
              transport.trigger("challengeReceived", envelope.payload)


    )


  class LocalStorageTransport
    constructor:(@userId, @gameId, @marshaller)->
      @marshaller ?= Factory.buildStateMarshaller()
    start = null
    startListening:()->
      handler = (event)=>
        keyParts = event.originalEvent.key.split("::")
        switch keyParts[0]
          when MESSAGE_QUEUE
            if keyParts[1] is @userId and (@gameId is keyParts[2] or (!@gameId? and !keyParts[2]?))
              dequeueMessage(@, @userId, @gameId)
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

