
rootLogger =
  addAppender:JsMockito.mockFunction()
  setLevel:JsMockito.mockFunction()

rootLoggerAppender = null

class mockConsoleAppender
  setThreshold:JsMockito.mockFunction()

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("log4JavaScript", "lib/logging/LoggerFactory", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      l4js=
        Level:
          WARN:"MOCK WARN LEVEL"
          TRACE:"MOCK TRACE LEVEL"
          FATAL:"MOCK FATAL LEVEL"
        getRootLogger:JsMockito.mockFunction()
        BrowserConsoleAppender:JsMockito.mockFunction()
      JsMockito.when(l4js.BrowserConsoleAppender)().then(()->
        rootLoggerAppender = new mockConsoleAppender()
        rootLoggerAppender
      )
      JsMockito.when(l4js.getRootLogger)().then(()->
        rootLogger
      )
      l4js
    )
  )
  Isolate.mapAsFactory("text!data/config.txt", "lib/logging/LoggerFactory", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      JSON.stringify(
        logLevel:"FATAL"
      )
    )
  )
)
define(["isolate!lib/logging/LoggerFactory", "jsMockito", "jsHamcrest", "chai"], (LoggerFactory, jm, h, c)->
  mocks = window.mockLibrary["lib/logging/LoggerFactory"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("LoggerFactory", ()->
    suite("Initial Load", ()->
      test("Appends BrowserAppender to root log4JavaScript logger", ()->
        jm.verify(rootLogger.addAppender)(m.instanceOf(mockConsoleAppender))
      )
      test("Sets added browserAppender threshold to TRACE", ()->
        jm.verify(rootLoggerAppender.setThreshold)("MOCK TRACE LEVEL")
      )
      test("Config has logLevel specified - sets log level to that specified in config (by property name, not value))", ()->
        jm.verify(rootLogger.setLevel)("MOCK FATAL LEVEL")
      )
    )
    suite("getLogger", ()->
      test("Returns log4javascript root logger", ()->
        a.equal(LoggerFactory.getLogger(), rootLogger)
      )
    )
  )


)

