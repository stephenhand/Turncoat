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
  Isolate.mapAsFactory("lib/turncoat/TypeRegistry", "lib/turncoat/GameHeader", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      registerType:JsMockito.mockFunction()
    )
  )
)


define(['isolate!lib/turncoat/GameHeader'], (GameHeader)->
  mocks = window.mockLibrary["lib/turncoat/GameHeader"]
  suite("GameHeader", ()->
    suite("constructor", ()->
      test("createdIsString_setsCreatedAsMomentUtc", ()->
        gh = new GameHeader({created:"MOCK_CREATED_TIME"})
        chai.assert.equal(gh.get("created"),"MOCK_MOMENT_UTC:MOCK_CREATED_TIME")
      )
      test("lastActivityIsString_setsLastActivityAsMomentUtc", ()->

        gh = new GameHeader({lastActivity:"MOCK_LASTACTIVITY_TIME"})
        chai.assert.equal(gh.get("lastActivity"),"MOCK_MOMENT_UTC:MOCK_LASTACTIVITY_TIME")
      )
    )
    suite("RegisterType", ()->
      test("registersGameHeaderConstriuctor", ()->
        JsMockito.verify(mocks["lib/turncoat/TypeRegistry"].registerType)("GameHeader",GameHeader)
      )

    )
  )


)

