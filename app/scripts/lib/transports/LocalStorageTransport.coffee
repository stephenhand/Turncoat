define(["underscore", "backbone", "jquery","uuid", "lib/logging/LoggerFactory", "lib/concurrency/Mutex", "lib/turncoat/Factory"], (_, Backbone, $, UUID, LoggerFactory, Mutex, Factory)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_ISSUED_MESSAGE_TYPE = "challenge-issued"
  EVENT_MESSAGE_TYPE = "event"

  log = LoggerFactory.getLogger()

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
              log.trace("DEQUEUE CRITICAL SECTION ENTERED, QUEUE FOUND: "+MESSAGE_QUEUE+"::"+id+", JSON:"+json)
              queue = transport.marshaller.unmarshalModel(json)
              messageId = queue.shift()?.get("id")
              remaining = queue.length

              log.trace("DEQUEUE CRITICAL SECTION MESSAGE FOUND: "+MESSAGE_QUEUE+"::"+id+", MESSAGE:"+messageId)
              window.localStorage.setItem(MESSAGE_QUEUE+"::"+id, transport.marshaller.marshalModel(queue))
              if messageId? and !window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)?
                throw new Error("Message missing for queued identifier "+messageId)
          success:()->
            log.trace("DEQUEUE CRITICAL SECTION SUCCESS CALLED, MESSAGEID "+(messageId ? "UNDEFINED")+", QUEUE: "+MESSAGE_QUEUE+"::"+id)
            if messageId?
              log.trace("DEQUEUE CRITICAL SECTION SUCCESS, ITEM FOUND: "+messageId+", QUEUE: "+MESSAGE_QUEUE+"::"+id)
              envelopeJSON = window.localStorage.getItem(MESSAGE_ITEM+"::"+messageId)
              if (envelopeJSON)
                try
                  envelope = transport.marshaller.unmarshalState(envelopeJSON)
                  switch envelope.get("type")
                    when CHALLENGE_ISSUED_MESSAGE_TYPE
                      log.trace("ISSUE CHALLENGE RECEIVED: "+envelopeJSON)
                      transport.trigger("challengeReceived", envelope.get("payload"))
                    when EVENT_MESSAGE_TYPE
                      log.trace("EVENT RECEIVED: "+envelopeJSON)
                      transport.trigger("eventReceived", envelope.get("payload"))
                finally
                  window.localStorage.removeItem(MESSAGE_ITEM+"::"+messageId)
              if remaining then dequeueMessage()
          error:(e)->
            log.trace(e)
            if messageId? && remaining then dequeueMessage()
        )

      enqueueMessage = (destination, id)->
        Mutex.lock(
          key:"LOCAL_TRANSPORT_MESSAGE_QUEUE::"+destination
          criticalSection:()->

            log.trace("ENQUEUE CRITICAL SECTION ENTERED: "+id)
            json = window.localStorage.getItem(MESSAGE_QUEUE+"::"+destination) ? "[]"

            log.trace("ENQUEUE CRITICAL SECTION QUEUE LOADED: "+id+", QUEUE NAME: "+MESSAGE_QUEUE+"::"+destination+", JSON:"+json)
            queue = transport.marshaller.unmarshalModel(json)
            queue.push(id:id)
            window.localStorage.setItem(MESSAGE_QUEUE+"::"+destination, transport.marshaller.marshalModel(queue))

            log.trace("ENQUEUE CRITICAL SECTION QUEUE SAVED: "+id+", QUEUE NAME: "+MESSAGE_QUEUE+"::"+destination+", JSON:"+transport.marshaller.marshalModel(queue))
            destParts =  destination.split("::")
            transportEventDispatcher.trigger("queueModified",
              userId:destParts[0]
              gameId:destParts[1])

            log.trace("ENQUEUE CRITICAL SECTION COMPLETED: "+id)
          success:()->
            log.trace("ENQUEUED: "+id)
          error:(e)->
            log.trace(e)
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
              new Backbone.Model(
                type:CHALLENGE_ISSUED_MESSAGE_TYPE
                payload:game
              )
            )
          )
          enqueueMessage(recipient, messageId)

      @broadcastGameEvent=(recipients, data, onComplete)->
        log.trace("BROADCASTING "+@gameId+" TO "+recipients)
        if (!@gameId?) then throw new Error("Only game level transports can broadcast game events.")
        if data? and recipients?
          for recipient in recipients
            messageId = UUID()
            window.localStorage.setItem(
              MESSAGE_ITEM+"::"+messageId,
              @marshaller.marshalState(
                new Backbone.Model(
                  type:EVENT_MESSAGE_TYPE
                  payload:data
                )
              )
            )
            log.trace("ENQUEUING: "+messageId)
            enqueueMessage(recipient+"::"+@gameId, messageId)




    stopListening:()->
    startListening:()->



  Factory.registerTransport("LocalStorageTransport",LocalStorageTransport)

  LocalStorageTransport
)

