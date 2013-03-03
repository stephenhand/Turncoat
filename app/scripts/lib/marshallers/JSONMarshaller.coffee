define([], ()->
  class JSONMarshaller
    marshalState:(stateObject)->
      JSON.stringify(stateObject)
    unmarshalState:(stateString)->
      throw new Error("Not implemented")
    marshalAction:(actionObject)->
      throw new Error("Not implemented")
    unmarshalAction:(actionString)->
      throw new Error("Not implemented")

  JSONMarshaller
)