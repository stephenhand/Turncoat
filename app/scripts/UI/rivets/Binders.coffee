require(["UI/rivets/binders/FeedItem"])

define(["jquery", "underscore","rivets"], ($, _, Rivets)->


  Binders =
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

  _.extend(Rivets.binders, Binders)
  Binders
)