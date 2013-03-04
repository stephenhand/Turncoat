define(["lib/turncoat/StateRegistry","backbone"], (StateRegistry, Backbone)->
  vivify = (dataObject)->
    dataObject[subObject] = vivify(dataObject[subObject]) for subObject of dataObject when typeof(dataObject[subObject])=="object"
    if (dataObject._type? && StateRegistry[dataObject._type]?)
      vivified = new StateRegistry[dataObject._type]()
      vivified.set(dataObject)
      vivified
    else
      new Backbone.Model(dataObject)

  recordType = (stateObject)->
    recordType(stateObject.attributes[subObject]) for subObject of stateObject.attributes when typeof(stateObject.attributes[subObject])=="object" and stateObject.attributes[subObject].set? and stateObject.attributes[subObject].attributes?
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

  JSONMarshaller
)