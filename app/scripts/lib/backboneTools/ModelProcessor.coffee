define(["underscore", "backbone"], (_, Backbone)->
  ModelProcessor =
    PREORDER:"MODELPROCESSOR-PREORDER"
    INORDER:"MODELPROCESSOR-INORDER"
    recurse:(item, processor, traversal)->
      searchSet
      if traversal is @PREORDER and !processor(item) then return false
      if item instanceof Backbone.Model
        searchSet = (item.attributes[searchItem] for searchItem of item.attributes when item.attributes[searchItem] instanceof Backbone.Model or item.attributes[searchItem] instanceof Backbone.Collection)
      else if item instanceof Backbone.Collection
        searchSet = (searchItem for searchItem in item.models when searchItem instanceof Backbone.Model or searchItem instanceof Backbone.Collection)
      else throw new Error("Only Backbone.Models and Backbone.Collections support recursiveSearch")
      windUp = false
      for setItem in searchSet
        if !@recurse(setItem, processor, traversal)
          windUp = true
          break
      if (traversal is @PREORDER) then return !windUp else return (processor(item) && !windUp)

    deepUpdate:(target, updated)->
      if target instanceof Backbone.Collection
        if not (updated instanceof Backbone.Collection) then throw new Error("Collections can only be deepUpdated with Collections")
      else if target instanceof Backbone.Model
        if not (updated instanceof Backbone.Model) then throw new Error("Models can only be deepUpdated with Models")
      else
        throw new Error("deepUpdate is for use with backbone models and collections only")
      stack = [
        updated
      ]
      @recurse(
        target
      ,
        (t)->
          u = stack.pop()
          if u isnt t
            newStack = []
            if t instanceof Backbone.Model
              atts = (for att,val of u.attributes
                if not (
                  (val instanceof Backbone.Model and t.get(att) instanceof Backbone.Model and val.id is t.get(att).id) or
                  (val instanceof Backbone.Collection and t.get(att) instanceof Backbone.Collection)
                ) then t.set(att, val)
                if val instanceof Backbone.Model or val instanceof Backbone.Collection then newStack.unshift(val)
                att
              )
              t.unset(att) for att of t.attributes when not _.contains(atts, att)
            else if t instanceof Backbone.Collection
              t.set(u.models, merge:false)
              for model in u.models
                newStack.unshift(model)
            stack = stack.concat(newStack)
            true
          else
            false


          true
      ,
        ModelProcessor.PREORDER
      )
      target


  ModelProcessor
)

