define 'cs!xlform/view.rowDetail', [
        'cs!xlform/model.utils',
        'cs!xlform/model.configs',
        'cs!xlform/view.utils',
        'cs!xlform/view.icons',
        'cs!xlform/view.rowDetail.SkipLogic',
        'cs!xlform/view.templates',
        ], (
            $modelUtils,
            $configs,
            $viewUtils,
            $icons,
            $viewRowDetailSkipLogic,
            $viewTemplates,
            )->

  viewRowDetail = {}

  class viewRowDetail.DetailView extends Backbone.View
    ###
    The DetailView class is a base class for details
    of each row of the XLForm. When the view is initialized,
    a mixin from "DetailViewMixins" is applied.
    ###
    className: "dt-view"
    initialize: ({@rowView})->
      unless @model.key
        throw new Error "RowDetail does not have key"
      @extraClass = "xlf-dv-#{@model.key}"
      if (viewMixin = viewRowDetail.DetailViewMixins[@model.key])
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
      $viewTemplates.$$render('xlfDetailView', @)

    insertInDOM: (rowView)->
      rowView.rowExtras.append(@el)

    renderInRowView: (rowView)->
      @render()
      @afterRender && @afterRender()
      @insertInDOM(rowView)
      @


  viewRowDetail.DetailViewMixins = {}

  viewRowDetail.DetailViewMixins.type =
    html: -> false
    insertInDOM: (rowView)->
      typeStr = @model.get("value").split(" ")[0]
      faClass = $icons.get(typeStr).get("faClass")
      rowView.$el.find(".card__header-icon").addClass("fa-#{faClass}")

  viewRowDetail.DetailViewMixins.label =
    html: -> false
    insertInDOM: (rowView)->
      if rowView.model.get("type").get("typeId") isnt "calculate"
        cht = rowView.$el.find(".card__header-title")
        cht.html(@model.get("value"))
        $viewUtils.makeEditable @, @model, cht, options:
          placement: 'right'
          rows: 3

  viewRowDetail.DetailViewMixins.hint =
    html: ->
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      $viewUtils.makeEditable @, @model, 'code', {}

  viewRowDetail.DetailViewMixins.relevant =
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
          @skipLogicEditor = new $viewRowDetailSkipLogic.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), model: @model)
          @skipLogicEditor.builder = @model.builder
          @skipLogicEditor.render()

  viewRowDetail.DetailViewMixins.constraint =
    html: ->
      """
        Validation logic (i.e. <span style='font-family:monospace'>constraint</span>):
        <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      $viewUtils.makeEditable @, @model, 'code', {}

  viewRowDetail.DetailViewMixins.name = viewRowDetail.DetailViewMixins.default =
    html: ->
      @listenTo @model, "change:value", ()=>
        @render()
        @afterRender()
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      $viewUtils.makeEditable @, @model, "code", transformFunction: $modelUtils.sluggify

  viewRowDetail.DetailViewMixins.calculation =
    html: -> false
    insertInDOM: (rowView)->
      if rowView.model.get("type").get("typeId") is "calculate"
        cht = rowView.$el.find(".card__header-title")
        cht.html(@model.get("value"))
        $viewUtils.makeEditable @, @model, cht, options:
          placement: 'right'
          rows: 3

  viewRowDetail.DetailViewMixins.required =
    html: ->
      """<label><input type="checkbox"> Required?</label>"""
    afterRender: ->
      inp = @$el.find("input")
      # to be moved into the model when XLF.configs.truthyValues is refactored
      isTrueValue = (@model.get("value") || "").toLowerCase() in $configs.truthyValues
      inp.prop("checked", isTrueValue)
      inp.change ()=> @model.set("value", inp.prop("checked"))

  viewRowDetail
