require(["UI/rivets/binders/FeedItem"])

define(["jquery", "underscore", "backbone", "sprintf", "rivets", "lib/2D/TransformBearings"], ($, _, Backbone, sprintf, Rivets, bearings)->


  RivetsExtensions =
    formatters:
      rotateCss:(input)->
        "rotate("+input+"deg)"
      toggle:(input, trueVal, falseVal)->
        if (input) then trueVal else falseVal
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
      calc:(input, mask)->
        if !mask? then return input
        vals = []
        if typeof input is "number"
          vals = [input]
        else
          for attr,idx in arguments when idx>1
            adapter = Rivets.adapters[Rivets.config.rootInterface]
            sectionStart = 0
            sectionEnd = 0
            val = input
            currentChar = 1
            while currentChar
              currentChar = attr.charAt(sectionEnd)
              if !currentChar or Rivets.adapters[currentChar]
                if sectionStart<sectionEnd
                  val = adapter.read(val, attr.substring(sectionStart, sectionEnd))
                adapter = Rivets.adapters[currentChar]
                sectionStart = sectionEnd+1
              sectionEnd++

            if typeof val is "number" then vals.push(val) else throw new Error("All inputs to calc formatter must be numeric.")

        vals.unshift(mask)
        eval(sprintf.apply(null, vals))


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

