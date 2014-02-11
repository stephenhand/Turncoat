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
      @recurse(
        target
      ,
        ()->
          true
      ,
        ModelProcessor.PREORDER
      )
      target


  ModelProcessor
)

