define(["operators"], (o)->
  (actualValue, matcherOrValue, message)->
    o.assert(actualValue, matcherOrValue,
      message: message,
      fail:  (msg)->
        throw new Error(msg);
    )
)

