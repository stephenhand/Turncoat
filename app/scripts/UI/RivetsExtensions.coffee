require(['UI/rivets/binders/FeedItem'])

define(['jquery', 'underscore', 'backbone', 'sprintf', 'rivets'], ($, _, Backbone, sprintf, Rivets)->


  RivetsExtensions =
    formatters:
      rotateCss:(input)->
        "rotate("+input+"deg)"
      toggle:(toggleSwitch, toggleValue)->
        if (toggleSwitch) then toggleValue else undefined
      sprintf:(input, mask)->
        sprintf(mask, input)
      multiplier:(input, multiplier, mask)->
        val = input * multiplier
        if isNaN(val) then val =input
        if (mask?) then val = sprintf(mask, val)
        val
      centroid:(input, posAtt, dimAtt)->
        pos = parseFloat(input.get(posAtt))
        posAdjust = parseFloat(input.get(dimAtt))/2
        if (isNaN(pos)) then throw new Error("Cannot set centroid to "+posAtt+" because "+posAtt+" is "+input.get(posAtt))
        if (isNaN(posAdjust)) then throw new Error("Cannot set centroid to  "+posAtt+" attribute because  "+dimAtt+" is "+input.get(dimAtt))
        return pos-posAdjust

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
        if @previousClass? then $(el).toggleClass(@previousClass, false)
        $(el).toggleClass(value, true)
        @previousClass = value
  _.extend(Rivets.binders, RivetsExtensions.binders)
  _.extend(Rivets.formatters, RivetsExtensions.formatters)
  RivetsExtensions
)

