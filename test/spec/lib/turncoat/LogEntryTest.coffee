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
      JsMockito.when(ret.utc)(JsHamcrest.Matchers.anything()).then((input)->
        "MOCK_MOMENT_UTC:"+input
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
    suite("constructor", ()->

      test("timeStampIsString_setsTimeStampAsMomentUtc", ()->
        le = new LogEntry({timestamp:"MOCK_TIME"})
        chai.assert.equal("MOCK_MOMENT_UTC:MOCK_TIME", le.get("timestamp"))
      )
      test("timeStampIsNotString_copiesTimestampAsIs", ()->
        le = new LogEntry({timestamp:{prop:"MOCK_TIME"}})
        chai.assert.equal("MOCK_TIME", le.get("timestamp").prop)
      )
    )
    suite("RegisterType", ()->
      test("usesLogEntryConstriuctor", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("LogEntry", LogEntry)
      )
    )
  )


)

