define(['jquery', 'underscore', 'backbone', 'sprintf', 'rivets'], ($, _, Backbone, sprintf, Rivets)->
  RivetsExtensions =
    formatters:
      rotateCss:(input)->
        "rotate("+input+"deg)"
      toggle:(toggleSwitch, toggleValue)->
        if (toggleSwitch) then toggleValue else undefined
      sprintf:(input, mask)->
        sprintf(mask, input)
    binders:
      style_top:(el, value)->
        el.style.top = value
      style_left:(el,value)->
        el.style.left=value
      style_transform:(el,value)->
        el.style.transform=value
        el.style.msTransform=value
        el.style.webkitTransform=value
      classappend:(el, value)->
        $(el).toggleClass(value, true)
  _.extend(Rivets.binders, RivetsExtensions.binders)
  _.extend(Rivets.formatters, RivetsExtensions.formatters)
  RivetsExtensions
)

