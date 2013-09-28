vivifierResult = undefined

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/GameStateModel","lib/turncoat/GameHeader", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = vivifier:JsMockito.mockFunction()
      JsMockito.when(ret.vivifier)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything()).then((u, c)->
        vivifierResult = {set:JsMockito.mockFunction()}
        return vivifierResult
      )
      ret
    )
  )
  Isolate.mapAsFactory("moment","lib/turncoat/GameHeader", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=
        utc:JsMockito.mockFunction()
      JsMockito.when(ret.utc)(JsHamcrest.Matchers.anything()).then((input)->
        "MOCK_MOMENT_UTC:"+input
      )
      ret
    )
  )
  Isolate.mapAsFactory("lib/turncoat/StateRegistry", "lib/turncoat/GameHeader", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      registerType:JsMockito.mockFunction()
    )
  )
)


define(['isolate!lib/turncoat/GameHeader'], (GameHeader)->
  mocks = window.mockLibrary["lib/turncoat/GameHeader"]
  suite("GameHeader", ()->
    suite("RegisterType", ()->
      test("usesGameStateModelVivifierWithDataAndGameHeaderConstriuctor", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("GameHeader", new JsHamcrest.SimpleMatcher(
          describeTo:(d)->d.append("vivified")
          matches:(v)->
            input={}
            v(input)
            try
              JsMockito.verify(mocks["lib/turncoat/GameStateModel"].vivifier)(input, GameHeader)
              true
            catch e
              false
        ))
      )
      test("setsCreatedAsMomentUtc", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("GameHeader",new JsHamcrest.SimpleMatcher(
          describeTo:(d)->d.append("vivified")
          matches:(v)->
            v(
              created:"MOCK_CREATED_TIME"
              lastActivity:"MOCK_LASTACTIVITY_TIME"
            )
            try
              JsMockito.verify(vivifierResult.set)("created","MOCK_MOMENT_UTC:MOCK_CREATED_TIME")
              true
            catch e
              false
        ))
      )
      test("setsLastActivityAsMomentUtc", ()->
        JsMockito.verify(mocks["lib/turncoat/StateRegistry"].registerType)("GameHeader",new JsHamcrest.SimpleMatcher(
          describeTo:(d)->d.append("vivified")
          matches:(v)->
            v(
              created:"MOCK_CREATED_TIME"
              lastActivity:"MOCK_LASTACTIVITY_TIME"
            )
            try
              JsMockito.verify(vivifierResult.set)("lastActivity","MOCK_MOMENT_UTC:MOCK_LASTACTIVITY_TIME")
              true
            catch e
              false
        ))
      )
    )
  )


)

