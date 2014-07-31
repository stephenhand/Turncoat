define(["underscore", "backbone"], (_, Backbone)->
  SVGTools  =
    pixelCoordsToSVGUnits:(element, xpx, ypx)->
      pxRect = element.getBoundingClientRect()
      svgRect = element.getBBox()
      coords =
        x:xpx*svgRect.width/pxRect.width
        y:ypx*svgRect.height/pxRect.height

      coords



  SVGTools
)

