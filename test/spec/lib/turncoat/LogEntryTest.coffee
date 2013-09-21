vivifierResult = undefined

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/GameStateModel","lib/turncoat/LogEntry", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = vivifier:JsMockito.mockFunction()
      JsMockito.when(ret.vivifier)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything()).then((u, c)->
        vivifierResult = {set:JsMockito.mockFunction()}
        return vivifierResult
      )
      ret
    )
  )
  Isolate.mapAsFactory("moment","lib/turncoat/LogEntry", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=
        utc:JsMockito.mockFunction()
      JsMockito.when(ret.utc)().then(()->
        "MOCK_MOMENT_CURRENT_UTC"
      )
      ret
    )
  )
  Isolate.mapAsFactory("lib/turncoat/StateRegistry", "lib/turncoat/LogEntry", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      registerType:JsMockito.mockFunction()
    )
  )
)

define(['isolate!lib/turncoat/LogEntry',], (LogEntry)->
  mocks = window.mockLibrary["lib/turncoat/LogEntry"]
  suite("LogEntry", ()->
    suite("RegisterType", ()->
      test("usesGameStateModelVivifierWithDataAndLogEntryConstriuctor", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("LogEntry", new JsHamcrest.SimpleMatcher(
          describeTo:(d)->d.append("vivified")
          matches:(v)->
            input={}
            v(input)
            try
              JsMockito.verify(mocks["lib/turncoat/GameStateModel"].vivifier)(input, LogEntry)
              true
            catch e
              false
        ))
      )
      test("setsTimeStampAsMomentUtc", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("LogEntry",new JsHamcrest.SimpleMatcher(
          describeTo:(d)->d.append("vivified")
          matches:(v)->
            v({})
            try
              JsMockito.verify(vivifierResult.set)("timestamp","MOCK_MOMENT_CURRENT_UTC")
              true
            catch e
              false
        ))
      )
    )
  )


)

