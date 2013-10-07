define(["rivets"], (rivets)->
  class FeedItem
    block: true

    bind: (el) ->
      unless @marker?
        attr = ['data', @view.config.prefix, @type].join('-').replace '--', '-'
        @marker = document.createComment " rivets: #{@type} "
        @iterated = []

        el.removeAttribute attr
        el.parentNode.insertBefore @marker, el
        el.parentNode.removeChild el

    unbind: (el) ->
      view.unbind() for view in @iterated if @iterated?

    routine: (el, collection) ->
      modelName = @args[0]
      modelIdentifierAttribute = @args[1]
      collection = collection or []
      lookup = {}

      #Assign existing items to new items in collection
      for each, index in collection
        lookup[index] = null
        for itItem, itIndex in @iterated
          if (itItem.identifier is each[modelIdentifierAttribute])
            lookup[itItem.identifier] = itItem
            itItem.retain = true
            if (itIndex+1<@iterated.length)
              for itIndexer in [itIndex+1..(@iterated.length-1)]
                it=@iterated[itIndexer]
                it.retain = false
                lookup[it.identifier] = null
            break

      #remove existing items not present in new collection
      for itItem in @iterated
        if !itItem.retain
          itItem.view.unbind()
          @marker.parentNode.removeChild(itItem.view.els[0])
      newIterated = []
      #process new collection
      previous = @marker
      for model, index in collection
        data = {}
        data[modelName] = model

        #not an existing item
        if not lookup[model[modelIdentifierAttribute]]?
          for key, viewmodel of @view.models
            data[key] ?= viewmodel
          i = index

          options =
            binders: @view.options.binders
            formatters: @view.options.formatters
            config: {}

          options.config[k] = v for k, v of @view.options.config
          options.config.preloadData = true

          template = el.cloneNode true
          view = new rivets._.View(template, data, options)
          view.bind()
          newIterated.push(
            view:view
            identifier:model[modelIdentifierAttribute]
          )
          @marker.parentNode.insertBefore(template, previous.nextSibling)
        else
          existing = lookup[model[modelIdentifierAttribute]]
          existing.retain = undefined
          existing.view.update(data)
          newIterated.push(existing)
        previous = previous.nextSibling
      @iterated = newIterated

    update: (models) ->
      data = {}

      for key, model of models
        data[key] = model unless key is @args[0]

      item.view.update data for item in @iterated

  rivets.binders["feeditem-*-*"]=new FeedItem()

  FeedItem
)

