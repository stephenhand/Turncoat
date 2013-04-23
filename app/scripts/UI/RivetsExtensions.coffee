define(['underscore', 'backbone', 'rivets'], (_, Backbone, Rivets)->
  RivetsExtensions =
    formatters:
      rotateCss:(input)->
        return "rotate("+input+"deg)"
    binders:
      style_top:(el, value)->
        el.style.top = value


  _.extend(Rivets.binders, RivetsExtensions.binders)
  _.extend(Rivets.formatters, RivetsExtensions.formatters)
  RivetsExtensions
)

