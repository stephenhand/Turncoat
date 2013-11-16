define(["underscore", "backbone", "jquery","uuid", "lib/concurrency/Mutex", "lib/turncoat/Factory"], (_, Backbone, $, UUID, Mutex, Factory)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_ISSUED_MESSAGE_TYPE = "challenge-issued"

  transportEventDispatcher = {}
  _.extend(transportEventDispatcher, Backbone.Events)

  class LocalStorageTransport

    constructor:(opt)->
      if (opt?)
        @userId = opt.userId
        @gameId = opt.gameId
        @marshaller = opt.marshaller
      otherListeningToggle = null
      remaining = 0
      @marshaller ?= Factory.buildStateMarshaller()

      _.extend(@, Backbone.Events)
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
              queue = transport.marshaller.unmarshalModel(json)
              messageId = queue.shift()
              remaining = queue.length
              window.localStorage.setItem(MESSAGE_QUEUE+"::"+id, transport.marshaller.marshalModel(queue))
              if messageId? and !window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)?
                throw new Error("Message missing for queued identifier "+messageId)
          success:()->
            if messageId?
              envelopeJSON = window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)
              if (envelopeJSON)
                try
                  envelope = transport.marshaller.unmarshalState(envelopeJSON)
                  switch envelope.get("type")
                    when CHALLENGE_ISSUED_MESSAGE_TYPE
                      transport.trigger("challengeReceived", envelope.get("payload"))
                finally
                  window.localStorage.removeItem(MESSAGE_ITEM+"::"+messageId)
              if remaining then dequeueMessage()
          error:(e)->
            if messageId? && remaining then dequeueMessage()
        )

      enqueueMessage = (recipient, id)->
        Mutex.lock(
          key:"LOCAL_TRANSPORT_MESSAGE_QUEUE::"+recipient
          criticalSection:()->
            json = window.localStorage.getItem(MESSAGE_QUEUE+"::"+recipient) ? "[]"
            queue = transport.marshaller.unmarshalModel(json)
            queue.push(id)
            window.localStorage.setItem(MESSAGE_QUEUE+"::"+recipient, transport.marshaller.marshalModel(queue))
          success:()->
        )

      @startListening=()->
        handler = (queueIdentity)=>
          if queueIdentity.userId is @userId and (@gameId is queueIdentity.gameId or (!@gameId? and !queueIdentity.gameId?))
            dequeueMessage()

        storageHandler  = (event)->
          keyParts = event.originalEvent.key.split("::")
          switch keyParts[0]
            when MESSAGE_QUEUE
              handler(
                userId:keyParts[1]
                gameId:keyParts[2]
              )

        $(window).on("storage", storageHandler)
        transportEventDispatcher.on("queueModified", handler)
        otherListeningToggle = @startListening
        @startListening = ()->
        @stopListening = ()->
          $(window).off("storage", storageHandler)
          transportEventDispatcher.off("queueModified", handler)
          @stopListening = ()->
          @startListening = otherListeningToggle
        dequeueMessage()

      @sendChallenge=(recipient, game)->
        if game?
          messageId = UUID()
          window.localStorage.setItem(
            MESSAGE_ITEM+"::"+messageId,
            @marshaller.marshalState(
              type:CHALLENGE_ISSUED_MESSAGE_TYPE
              payload:game
            )
          )
          enqueueMessage(recipient, messageId)

    stopListening:()->
    startListening:()->



  Factory.registerTransport("LocalStorageTransport",LocalStorageTransport)

  LocalStorageTransport
)
