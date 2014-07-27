define(["underscore", "backbone"], (_, Backbone)->
  cryptoStub =
    MD5:(input)->
      total = 0
      i = input.length
      while i--
         total+=input.charCodeAt(i)
      return total;


  cryptoStub
)

