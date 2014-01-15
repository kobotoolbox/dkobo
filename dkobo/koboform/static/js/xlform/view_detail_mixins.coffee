#meant to be bound to a backbone view

@DetailViewMixins = {}

DetailViewMixins.type =
  html: -> false
  afterRender: ->
    @$el.css width: 40, height: 40
    tps = @model.get('typeId')
    @$el.attr("title", "Row Type: #{tps}")
    @$el.addClass("rt-#{tps}")
    @$el.addClass("type-icon")
  insertInDOM: (rowView)->
    rowView.$(".row-type").append(@$el)

DetailViewMixins.label =
  html: ->
    """
    <div class="col-md-12">
      <blockquote style="display: inline-block">
        #{@model.get("value")}
      </blockquote>
    </div>
    """
  insertInDOM: (rowView)->
    rowView.rowContent.prepend(@$el)

  afterRender: ->
    viewUtils.makeEditable @, @model, 'blockquote', options:
      placement: 'right'
      rows: 3

DetailViewMixins.hint =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

DetailViewMixins.relevant = 
  html: ->
    """
      <button>Skip Logic</button>
    """

  afterRender: ->
    viewCreated = false
    view = undefined
    button = @$el.find("button")
    button.click () =>
      @skipLogicClause = new XLF.SkipLogicClause()
      @skipLogicClause.parent = @model
      @skipLogicClause.parse(@model.get('value'))
      @model.parentRow.skipLogicClause = @skipLogicClause

      if (!viewCreated)
        view = new XLF.SkipLogicView(relevantDetailView: @, model: @skipLogicClause)
        viewCreated = true

      view.render(@$el)

    viewUtils.makeEditable @, @model, 'code', {}

DetailViewMixins.constraint = 
  html: ->
    """
      Validation logic (i.e. <span style='font-family:monospace'>constraint</span>):
      <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

DetailViewMixins.name =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, "code", transformFunction: XLF.sluggify

DetailViewMixins.required =
  html: ->
    """<label><input type="checkbox"> Required?</label>"""
  afterRender: ->
    inp = @$el.find("input")
    inp.prop("checked", @model.get("value"))
    inp.change ()=> @model.set("value", inp.prop("checked"))