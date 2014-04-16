class XLF.Option extends XLF.BaseModel
  initialize: -> @unset("list name")
  destroy: ->
    log "destroy me", @
  list: -> @collection
  toJSON: ()->
    name: @get("name")
    label: @get("label")

class XLF.Options extends XLF.BaseCollection
  model: XLF.Option

class XLF.ChoiceList extends XLF.BaseModel
  idAttribute: "name"
  constructor: (opts={}, context)->
    options = opts.options || []
    super name: opts.name, context
    @options = new XLF.Options(options || [], _parent: @)
  summaryObj: ->
    @toJSON()
  finalize: ->
    # ensure that all options have names
    names = []
    for option in @options.models
      label = option.get("label")
      name = option.get("name")
      if not name
        name = XLF.sluggifyLabel(label, names)
        option.set("name", name)
      names.push name
    ``

  toJSON: ()->
    @finalize()

    # Returns {name: '', options: []}
    name: @get("name")
    options: @options.invoke("toJSON")

  getNames: ()->
    names = @options.map (opt)-> opt.get("name")
    _.compact names

class XLF.ChoiceLists extends XLF.BaseCollection
  model: XLF.ChoiceList
  summaryObj: ()->
    out = {}
    for model in @models
      out[model.get("name")] = model.summaryObj()
    out
