define(["underscore", "backbone", "jquery","uuid", "lib/concurrency/Mutex", "lib/turncoat/Factory"], (_, Backbone, $, UUID, Mutex, Factory)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_RECEIVED_MESSAGE_TYPE = "challenge-received"

  enqueueMessage = (recipient, gameId, payload)->




  class LocalStorageTransport
    otherListeningToggle = null
    dequeueMessage = null

    constructor:(@userId, @gameId, @marshaller)->
      remaining = 0
      @marshaller ?= Factory.buildStateMarshaller()
      transport = @

      dequeueMessage = ()->
        id = transport.userId
        if transport.gameId? then id+="::"+transport.gameId
        messageId = null
        Mutex.lock(
          key:"LOCAL_TRANSPORT_MESSAGE_QUEUE::"+id
          criticalSection:()->
            json = window.localStorage.getItem(MESSAGE_QUEUE+"::"+id)
            if json?
              queue = transport.marshaller.unmarshalState(json)
              messageId = queue.shift()
              remaining = queue.length
              window.localStorage.setItem(MESSAGE_QUEUE+"::"+id, transport.marshaller.marshalState(queue))
              if messageId? and !window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)?
                throw new Error("Message missing for queued identifier "+messageId)
          success:()->
            if (messageId?)
              envelopeJSON = window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)
              if (envelopeJSON)
                envelope = transport.marshaller.unmarshalModel(envelopeJSON)
                switch envelope.type
                  when CHALLENGE_RECEIVED_MESSAGE_TYPE
                    transport.trigger("challengeReceived", envelope.payload)
              if remaining then dequeueMessage()
          error:(e)->
            if remaining then dequeueMessage()
        )

    startListening:()->
      handler = (event)=>
        keyParts = event.originalEvent.key.split("::")
        switch keyParts[0]
          when MESSAGE_QUEUE
            if keyParts[1] is @userId and (@gameId is keyParts[2] or (!@gameId? and !keyParts[2]?))
              dequeueMessage(@, @userId, @gameId)
      $(window).on("storage", handler)
      otherListeningToggle = @startListening
      @startListening = ()->
      @stopListening = ()->
        $(window).off("storage", handler)
        @stopListening = ()->
        @startListening = otherListeningToggle


    stopListening:()->


  LocalStorageTransport
)

