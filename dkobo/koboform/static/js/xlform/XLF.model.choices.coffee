class XLF.Option extends XLF.BaseModel
  initialize: -> @unset("list name")
  destroy: ->
    log "destroy me", @
  list: -> @collection
  toJSON: ()->
    label = @get("label")
    name = @get("name") || XLF.sluggify(label)
    {name: name, label: label}

class XLF.Options extends XLF.BaseCollection
  model: XLF.Option

class XLF.ChoiceList extends XLF.BaseModel
  idAttribute: "name"
  constructor: (opts={}, context)->
    options = opts.options || []
    super name: opts.name, context
    @options = new XLF.Options(options || [], _parent: @)
  summaryObj: ->
    name: @get("name")
    options: @options.models.map("toJSON")
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
