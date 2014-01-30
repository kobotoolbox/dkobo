#meant to be bound to a backbone view

@DetailViewMixins = {}

DetailViewMixins.type =
  html: -> false
  insertInDOM: (rowView)->
    typeStr = @model.get("value").split(" ")[0]
    faClass = XLF.icons.get(typeStr).get("faClass")
    rowView.$el.find(".card__header-icon").addClass("fa-#{faClass}")

DetailViewMixins.label =
  html: -> false
  insertInDOM: (rowView)->
    cht = rowView.$el.find(".card__header-title")
    cht.html(@model.get("value"))
    viewUtils.makeEditable @, @model, cht, options:
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
      <div class="relevant__editor"></div>
    """

  afterRender: ->
    button = @$el.find("button").eq(0)
    button.click () =>
      if @skipLogicEditor
        @skipLogicEditor.toggle()
      else
        if !@model.skipLogicCollection
          throw new Error("Skip Logic Colleciton not found for RowDetail model.")

        @skipLogicEditor = new XLF.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), collection: @model.skipLogicCollection).render()

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