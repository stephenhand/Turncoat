define(["lib/turncoat/StateRegistry","backbone", "lib/turncoat/Factory"], (StateRegistry, Backbone, Factory)->
  vivify = (dataObject, ignoreTypeInfo)->
    if (Array.isArray(dataObject))
      dataObject[index] = vivify(subObject) for subObject, index in dataObject when (typeof(subObject)=="object")
      new Backbone.Collection(dataObject)
    else
      dataObject[subObject] = vivify(dataObject[subObject]) for subObject of dataObject when (typeof(dataObject[subObject])=="object")
      dataObject[subObject]
      if (!ignoreTypeInfo && dataObject._type? && StateRegistry[dataObject._type]?)
        vivified = new StateRegistry[dataObject._type]()
        vivified.set(dataObject)
        vivified.unset("_type")
        vivified._type = undefined
        vivified
      else
        new Backbone.Model(dataObject)

  recordType = (stateObject)->
    if (stateObject instanceof Backbone.Collection)
      recordType(subObject) for subObject in stateObject.models when subObject instanceof Backbone.Collection or subObject instanceof Backbone.Model

    recordType(stateObject.attributes[subObject]) for subObject of stateObject.attributes when stateObject.attributes[subObject] instanceof Backbone.Collection or stateObject.attributes[subObject] instanceof Backbone.Model
    if (stateObject instanceof Backbone.Model)
      stateObject.set(
        "_type" : StateRegistry.reverse[stateObject.constructor]
      )

  forgetType = (stateObject)->
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
      vivify(dataObject)

    marshalAction:(actionObject)->
      throw new Error("Not implemented")

    unmarshalAction:(actionString)->
      throw new Error("Not implemented")

    unmarshalModel:(modelJSON)->
      pojso = JSON.parse(modelJSON)
      vivify(pojso, true)

    marshalModel:(model)->
      if (model instanceof Backbone.Collection or model instanceof Backbone.Model)
        return JSON.stringify(model)
      else throw new Error("Only backbone models and collections are marshalled")

  Factory.registerStateMarshaller("JSONMarshaller",JSONMarshaller)
  JSONMarshaller
)