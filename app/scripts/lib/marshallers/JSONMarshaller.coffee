define(["lib/turncoat/TypeRegistry","backbone", "lib/turncoat/Factory"], (TypeRegistry, Backbone, Factory)->
  vivify = (rootObject, options)->
    vivifiedRoot = null
    vivifyRecursive = (dataObject)->
      if (Array.isArray(dataObject))
        ret = null
        dataObject[index] = vivifyRecursive(subObject, options) for subObject, index in dataObject when (typeof(subObject)=="object")
        ret = new Backbone.Collection(dataObject)
      else
        dataObject[subObject] = vivifyRecursive(dataObject[subObject], options) for subObject of dataObject when (typeof(dataObject[subObject])=="object")
        dataObject[subObject]
        if (!(options?.ignoreTypeInfo) && dataObject._type? && TypeRegistry[dataObject._type]?)
          ret = new TypeRegistry[dataObject._type](dataObject)
        else
          ret = new Backbone.Model(dataObject)
      if options?.setRootLinkback and dataObject isnt rootObject then ret.getRoot = ()->
        vivifiedRoot
      ret
    vivifiedRoot = vivifyRecursive(rootObject)
    vivifiedRoot


  recordType = (stateObject)->
    if (stateObject instanceof Backbone.Collection)
      recordType(subObject) for subObject in stateObject.models when subObject instanceof Backbone.Collection or subObject instanceof Backbone.Model

    recordType(stateObject.attributes[subObject]) for subObject of stateObject.attributes when stateObject.attributes[subObject] instanceof Backbone.Collection or stateObject.attributes[subObject] instanceof Backbone.Model
    if (stateObject instanceof Backbone.Model)
      stateObject.set(
        "_type" : TypeRegistry.reverseLookup(stateObject.constructor)
      )
      if (!stateObject.get("id")?) then stateObject.set("id", stateObject.id)

  forgetType = (stateObject)->
    if (stateObject instanceof Backbone.Collection)
      forgetType(subObject) for subObject in stateObject.models
    else if (stateObject instanceof Backbone.Model)
      forgetType(stateObject.attributes[subObject]) for subObject of stateObject.attributes when typeof(stateObject.attributes[subObject])=="object" and stateObject.attributes[subObject].set? and stateObject.attributes[subObject].attributes?
      stateObject.unset("_type")


  class JSONMarshaller
    marshalState:(stateObject)->
      recordType(stateObject)
      marshalled = JSON.stringify(stateObject)
      forgetType(stateObject)
      marshalled

    unmarshalState:(stateString)->
      dataObject = JSON.parse(stateString)
      vivify(dataObject, setRootLinkback:true)


    marshalAction:(actionObject)->
      @marshalState(actionObject)

    unmarshalAction:(actionString)->
      @unmarshalState(actionString)

    unmarshalModel:(modelJSON)->
      pojso = JSON.parse(modelJSON)
      vivify(pojso, ignoreTypeInfo:true)

    marshalModel:(model)->
      if (model instanceof Backbone.Collection or model instanceof Backbone.Model)
        return JSON.stringify(model)
      else throw new Error("Only backbone models and collections are marshalled")

  Factory.registerStateMarshaller("JSONMarshaller",JSONMarshaller)
  JSONMarshaller
)