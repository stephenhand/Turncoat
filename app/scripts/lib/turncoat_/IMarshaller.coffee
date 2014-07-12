define([], ()->
  class IMarshaller
    marshalState:(stateObject)->
      throw new Error("Not implemented")
    unmarshalState:(stateString)->
      throw new Error("Not implemented")
    marshalAction:(actionObject)->
      throw new Error("Not implemented")
    unmarshalAction:(actionString)->
      throw new Error("Not implemented")
  IMarshaller
)