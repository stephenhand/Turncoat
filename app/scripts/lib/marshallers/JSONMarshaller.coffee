define(["lib/turncoat/StateRegistry"], (StateRegistry)->
  class JSONMarshaller
    marshalState:(stateObject)->
      stateObject.set(
        "_type" : StateRegistry.reverse[stateObject.constructor]
      )
      marshalled = JSON.stringify(stateObject)
      stateObject.unset("_type")
      marshalled

    unmarshalState:(stateString)->
      throw new Error("Not implemented")
    marshalAction:(actionObject)->
      throw new Error("Not implemented")
    unmarshalAction:(actionString)->
      throw new Error("Not implemented")

  JSONMarshaller
)