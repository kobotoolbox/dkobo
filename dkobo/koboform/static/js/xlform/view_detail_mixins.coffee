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
      type: 'textarea'
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
      Skip logic (i.e. <span style='font-family:monospace'>relevant</span>):
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