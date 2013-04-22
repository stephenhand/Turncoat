define(['underscore', 'backbone', 'rivets'], (_, Backbone, Rivets)->
  RivetsExtensions =
    formatters:
    binders:


  _.extend(Rivets.binders, RivetsExtensions.binders)
  _.extend(Rivets.formatters, RivetsExtensions.formatters)
  RivetsExtensions
)

