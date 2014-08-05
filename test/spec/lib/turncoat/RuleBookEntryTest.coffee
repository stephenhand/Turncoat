require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!lib/turncoat/RuleBookEntry", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(RuleBookEntry, m, o, a, jm, v)->
  mocks = window.mockLibrary["lib/turncoat/RuleBookEntry"]
  suite("RuleBookEntry", ()->
    suite("getDescription", ()->
      test("throws", ()->
        a(new RuleBookEntry().getDescription, m.raisesAnything())
      )
    )
    suite("getActionRules", ()->
      test("throws", ()->
        a(new RuleBookEntry().getActionRules, m.raisesAnything())
      )
    )
    suite("getEventRules", ()->
      test("throws", ()->
        a(new RuleBookEntry().getEventRules, m.raisesAnything())
      )
    )
    suite("lookUp", ()->
      rules = null
      setup(()->
        rules = {
          "ENTRY1":
            lookUp:jm.mockFunction()
          "ENTRY2":
            lookUp:jm.mockFunction()
        }
        jm.when(rules.ENTRY2.lookUp)(m.anything()).then((input)->"LOOKUP::"+input)
      )
      test("missing path - throws", ()->
        a(()->
          new RuleBookEntry(rules).lookUp()
        , m.raisesAnything())
      )
      test("empty path - returns nothing", ()->
        a(new RuleBookEntry(rules).lookUp(""), m.nil())
      )
      suite("Single part path.", ()->
        test("rules not specified - returns nothing", ()->
          a(new RuleBookEntry().lookUp("ANYTHING"), m.nil())
        )
        test("rules specified but none match - returns nothing", ()->
          a(new RuleBookEntry(rules).lookUp("ANYTHING"), m.nil())
        )
        test("rules specified with match - returns rule", ()->
          a(new RuleBookEntry(rules).lookUp("ENTRY2"), rules.ENTRY2)
        )
      )
      suite("multi-part path.", ()->
        test("Rules not specified - throws", ()->
          a(()->
            new RuleBookEntry().lookUp("ANYTHING.ELSE")
          , m.raisesAnything())
        )
        test("Rules specified but first part of path does not match - throws", ()->
          a(()->
            new RuleBookEntry(rules).lookUp("ANYTHING.ELSE")
          , m.raisesAnything())
        )
        test("Rules specified with match - calls lookup on matched rule and returns result", ()->
          res = new RuleBookEntry(rules).lookUp("ENTRY2.ELSE")
          jm.verify(rules.ENTRY2.lookUp)("ELSE")
          a(res, "LOOKUP::ELSE")
        )
        test("Rules specified with match which has no lookup function - throws", ()->
          delete rules.ENTRY2.lookUp
          a(()->
            new RuleBookEntry(rules).lookUp("ENTRY2.ELSE")
          , m.raisesAnything())
        )
        test("Sub entry's lookup throws - throws", ()->
          jm.when(rules.ENTRY2.lookUp)(m.anything()).then(()->throw new Error())
          a(()->
            new RuleBookEntry(rules).lookUp("ENTRY2.ELSE")
          , m.raisesAnything())
        )
      )
    )
  )
)

