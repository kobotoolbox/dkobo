define 'cs!xlform/model.choices', [
        'cs!xlform/model.base',
        'cs!xlform/model.utils',
        ], (
            base,
            $modelUtils,
            )->

  choices = {}

  class choices.Option extends base.BaseModel
    initialize: -> @unset("list name")
    destroy: ->
      log "destroy me", @
    list: -> @collection
    toJSON: ()->
      name: @get("name")
      label: @get("label")

  class choices.Options extends base.BaseCollection
    model: choices.Option

  class choices.ChoiceList extends base.BaseModel
    idAttribute: "name"
    constructor: (opts={}, context)->
      options = opts.options || []
      super name: opts.name, context
      @options = new choices.Options(options || [], _parent: @)
    summaryObj: ->
      @toJSON()
    finalize: ->
      # ensure that all options have names
      names = []
      for option in @options.models
        label = option.get("label")
        name = option.get("name")
        if not name
          name = $modelUtils.sluggify(label, {
            preventDuplicates: names
            lowerCase: true
            lrstrip: true
            characterLimit: 14
            incrementorPadding: false
            validXmlTag: false
          })
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

  class choices.ChoiceLists extends base.BaseCollection
    model: choices.ChoiceList
    summaryObj: (shorter=false)->
      out = {}
      for model in @models
        if shorter
          out[model.get("name")] = model.summaryObj().options
        else
          out[model.get("name")] = model.summaryObj()
      out

  choices
