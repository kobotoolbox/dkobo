# enketoIframe = do ->

@viewUtils = {}

viewUtils.makeEditable = (that, model, selector, {property, transformFunction, options}) ->
  if !transformFunction?
    transformFunction = (value) -> value
  if !property?
    property = 'value'
  
  opts = 
    type: 'text'
    success: _.bind (uu, ent) ->
        ent = transformFunction ent
        model.set(property, ent, validate: true)
        if(model.validationError && model.validationError[property])
          return model.validationError[property]

        newValue: ent
      , that

  editableOpts = _.extend(opts, options)

  if selector instanceof jQuery
    selector.editable editableOpts
  else
    that.$el.find(selector).editable editableOpts


viewUtils.reorderElemsByData = (selector, parent, dataAttribute)->
  arr = []
  parentEl = false
  $(parent).find(selector).each (i)->
    if i is 0
      parentEl = @parentElement
    else if @parentElement isnt parentEl
      throw new Error("All reordered items must be siblings")

    $el = $(@).detach()
    val = $el.data(dataAttribute)
    arr[val] = $el  if _.isNumber(val)
  $el.appendTo(parentEl)  for $el in arr when $el
  ``

XLF.enketoIframe = do ->

  buildUrl = (previewUrl)->
    fullPreviewUrl = "#{window.location.origin}#{previewUrl}"
    """https://enketo.org/webform/preview?form=#{fullPreviewUrl}"""

  clickCloserBackground = ->
    $("<div>", class: "js-click-remove-iframe")

  launch = (previewUrl)->
    wrap = $("<div>", class: "js-click-remove-iframe iframe-bg-shade")
    $("<iframe>", src: buildUrl(previewUrl)).appendTo(wrap)
    wrap.click ()-> wrap.remove()
    wrap

  launch.close = ()->
    $(".iframe-bg-shade").remove()

  launch
