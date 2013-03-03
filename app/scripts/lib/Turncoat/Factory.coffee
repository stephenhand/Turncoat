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
    new factory[type][key ? (factory.defaults[type])](opts)

  Factory =
    buildStateMarshaller:(key, opts)->
      buildFactoryType(@, "stateMarshaller", key, opts)

    registerStateMarshaller:(key, marshallerClass)->
      registerFactoryType(@, "stateMarshaller", key, marshallerClass)




  Factory
)