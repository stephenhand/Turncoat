define([], ()->
  window.mockLibrary = {}
  window.mockLibrary.actuals?={}
  return {
    mapAndRecord : (actual, path, requestingModulePath, mapFunc)->
      window.mockLibrary[requestingModulePath] ?= {}
      mock = mapFunc()
      window.mockLibrary[requestingModulePath][path]=mock
      window.mockLibrary.actuals[path]?=actual
      mock
  }
)

