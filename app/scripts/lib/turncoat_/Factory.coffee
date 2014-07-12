define(["underscore"], (_)->
  registerFactoryType = (factory, type, key, classConstructor)->
    if (!factory[type]?)
      factory[type] = []
    factory[type][key] = classConstructor

  buildFactoryType = (factory, type, key, opts) ->
    if (key? && !_.isString(key))
      #opts passed in for default of this type
      opts = key
      key = undefined
    fc =factory[type][key ? (factory.defaults[type])]
    if fc?
      new fc(opts)
    else
      null

  setDefaultFactory = (factory, type, key)->
    factory.defaults[type] = key

  Factory =
    defaults:{}
    buildStateMarshaller:(key, opts)->
      buildFactoryType(@, "stateMarshaller", key, opts)

    registerStateMarshaller:(key, marshallerClass)->
      registerFactoryType(@, "stateMarshaller", key, marshallerClass)

    setDefaultMarshaller:(marshallerClassKey)->
      setDefaultFactory(@, "stateMarshaller", marshallerClassKey)

    buildPersister:(key, opts)->
      buildFactoryType(@, "persister", key, opts)

    registerPersister:(key, persisterClass)->
      registerFactoryType(@, "persister", key, persisterClass)

    setDefaultPersister:(persisterClassKey)->
      setDefaultFactory(@, "persister", persisterClassKey)

    buildTransport:(key, opts)->
      buildFactoryType(@, "transport", key, opts)

    registerTransport:(key, transportClass)->
      registerFactoryType(@, "transport", key, transportClass)

    setDefaultTransport:(transportClassKey)->
      setDefaultFactory(@, "transport", transportClassKey)


  Factory
)