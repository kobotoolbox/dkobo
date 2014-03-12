# class XlfDetailView extends Backbone.View
# class XLF.SkipLogicCriterionView extends Backbone.View
# class XLF.SkipLogicCollectionView extends Backbone.View

class XLF.DetailView extends Backbone.View
  ###
  The XlfDetailView class is a base class for details
  of each row of the XLForm. When the view is initialized,
  a mixin from "XLF.DetailViewMixins" is applied.
  ###
  className: "dt-view"
  initialize: ({@rowView})->
    unless @model.key
      throw new Error "RowDetail does not have key"
    @extraClass = "xlf-dv-#{@model.key}"
    if (viewMixin = XLF.DetailViewMixins[@model.key])
      _.extend(@, viewMixin)
    else
      console?.error "couldn't find ", @model.key
    @$el.addClass(@extraClass)

  render: ()->
    rendered = @html()
    if rendered
      @$el.html rendered
    @
  html: ()->
    viewTemplates.xlfDetailView @

  insertInDOM: (rowView)->
    rowView.rowExtras.append(@el)

  renderInRowView: (rowView)->
    @render()
    @afterRender && @afterRender()
    @insertInDOM(rowView)
    @


XLF.DetailViewMixins = {}

XLF.DetailViewMixins.type =
  html: -> false
  insertInDOM: (rowView)->
    typeStr = @model.get("value").split(" ")[0]
    faClass = XLF.icons.get(typeStr).get("faClass")
    rowView.$el.find(".card__header-icon").addClass("fa-#{faClass}")

XLF.DetailViewMixins.label =
  html: -> false
  insertInDOM: (rowView)->
    if rowView.model.get("type").get("typeId") isnt "calculate"
      cht = rowView.$el.find(".card__header-title")
      cht.html(@model.get("value"))
      viewUtils.makeEditable @, @model, cht, options:
        placement: 'right'
        rows: 3

XLF.DetailViewMixins.hint =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

XLF.DetailViewMixins.relevant =
  html: ->
    """
      <button>Skip Logic</button>
      <div class="relevant__editor"></div>
    """

  afterRender: ->
    button = @$el.find("button").eq(0)
    button.click () =>
      if @skipLogicEditor
        @skipLogicEditor.toggle()
      else
        @skipLogicEditor = new XLF.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), model: @model)
        @skipLogicEditor.builder = @model.builder
        @skipLogicEditor.render()

XLF.DetailViewMixins.constraint =
  html: ->
    """
      Validation logic (i.e. <span style='font-family:monospace'>constraint</span>):
      <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

XLF.DetailViewMixins.name = XLF.DetailViewMixins.default =
  html: ->
    @listenTo @model, "change:value", ()=>
      @render()
      @afterRender()
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, "code", transformFunction: XLF.sluggify

XLF.DetailViewMixins.calculation =
  html: -> false
  insertInDOM: (rowView)->
    if rowView.model.get("type").get("typeId") is "calculate"
      cht = rowView.$el.find(".card__header-title")
      cht.html(@model.get("value"))
      viewUtils.makeEditable @, @model, cht, options:
        placement: 'right'
        rows: 3

XLF.DetailViewMixins.required =
  html: ->
    """<label><input type="checkbox"> Required?</label>"""
  afterRender: ->
    inp = @$el.find("input")
    inp.prop("checked", @model.get("value"))
    inp.change ()=> @model.set("value", inp.prop("checked"))
