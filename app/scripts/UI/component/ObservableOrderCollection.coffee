define(["underscore", "backbone"], (_, Backbone)->
  resetOrder = (models, attribute)->
    model.set(attribute, index) for model, index in models
  unsetOrder = (models, attribute)->
    model.unset(attribute) for model in models

  ObservableOrderCollection=

    setOrderAttribute:(name)->
      if !name? then throw new Exception("An attribute name to store ordinals under must be specified")
      resetOrder(@models, name)
      handler = ()=>resetOrder(@models, name)

      @on("add", handler, @)
      @on("remove", handler, @)
      @on("reset", handler, @)

      disabledFunc = @setOrderAttribute
      @setOrderAttribute = ()->

      @unsetOrderAttribute = ()->
        unsetOrder(@models, name)
        @off("add", handler, @)
        @off("remove", handler, @)
        @off("reset", handler, @)
        @setOrderAttribute = disabledFunc
        disabledFunc = @unsetOrderAttribute
        @unsetOrderAttribute = ()->

    unsetOrderAttribute:()->


  ObservableOrderCollection
)

