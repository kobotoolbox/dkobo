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
    className: "card__settings__fields__field  dt-view dt-view--depr"
    initialize: ({@rowView})->
      unless @model.key
        throw new Error "RowDetail does not have key"
      @extraClass = "xlf-dv-#{@model.key}"
      if (viewMixin = viewRowDetail.DetailViewMixins[@model.key])
        _.extend(@, viewMixin)
      else
        console?.error "Couldn't build view for column: ", @model.key
      @$el.addClass(@extraClass)

    render: ()->
      rendered = @html()
      if rendered
        @$el.html rendered
      @
    html: ()->
      $viewTemplates.$$render('xlfDetailView', @)
    listenForCheckboxChange: (opts={})->
      el = opts.el || @$('input[type=checkbox]').get(0)
      $el = $(el)
      changing = false
      reflectValueInEl = ()=>
        if !changing
          val = @model.get('value')
          if val is true or val in $configs.truthyValues
            $el.prop('checked', true)
      @model.on 'change:value', reflectValueInEl
      reflectValueInEl()
      $el.on 'change', ()=>
        changing = true
        @model.set('value', $el.prop('checked'))
        changing = false
    listenForInputChange: (opts={})->
      # listens to checkboxes and input fields and ensures
      # the model's value is reflected in the element and changes
      # to the element are reflected in the model (with transformFn
      # applied)
      el = opts.el || @$('input').get(0)
      $el = $(el)
      transformFn = opts.transformFn || false
      inputType = opts.inputType
      inTransition = false

      changeModelValue = ($elVal)=>
        # preventing race condition
        if !inTransition
          inTransition = true
          @model.set('value', $elVal)
          reflectValueInEl(true)
          inTransition = false

      reflectValueInEl = (force=false)=>
        # This should never change the model value
        if force || !inTransition
          modelVal = @model.get('value')
          if inputType is 'checkbox'
            if !_.isBoolean(modelVal)
              modelVal = modelVal in $configs.truthyValues
            # triggers element change event
            $el.prop('checked', modelVal)
          else
            # triggers element change event
            $el.val(modelVal)

      reflectValueInEl()
      @model.on 'change:value', reflectValueInEl

      $el.on 'change', ()=>
        $elVal = $el.val()
        if transformFn
          $elVal = transformFn($elVal)
        changeModelValue($elVal)
      return

    insertInDOM: (rowView)->
      rowView.defaultRowDetailParent.append(@el)

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
      if !(@model._parent.constructor.kls is "Group")
        faClass = $icons.get(typeStr).get("faClass")
        rowView.$el.find(".card__header-icon").addClass("fa-#{faClass}")


  viewRowDetail.DetailViewMixins.label =
    html: -> false
    insertInDOM: (rowView)->
      cht = rowView.$label
      cht.html(@model.get("value"))
      $viewUtils.makeEditable @, @model, cht, options:
        placement: 'right'
        rows: 3

  viewRowDetail.DetailViewMixins.hint = viewRowDetail.DetailViewMixins.default =
    html: ->
      @$el.addClass("card__settings__fields--active")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">#{@model.key}: </label>
        <span class="settings__input">
          <input type="text" name="#{@model.key}" id="#{@cid}" class="text" />
        </span>
      </div>
      """
    afterRender: ->
      @listenForInputChange()

  viewRowDetail.DetailViewMixins.constraint_message =
    html: ->
      @$el.addClass("card__settings__fields--active")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">Error Message: </label>
        <span class="settings__input">
          <input type="text" name="#{@model.key}" id="#{@cid}" class="text" />
        </span>
      </div>
      """
    insertInDOM: (rowView)->
      rowView.cardSettingsWrap.find('.card__settings__fields--validation-criteria').eq(0).append(@el)
    afterRender: ->
      @listenForInputChange()

  viewRowDetail.DetailViewMixins.relevant =
    html: ->
      @$el.addClass("card__settings__fields--active")
      """
      <div class="card__settings__fields__field relevant__editor">
      </div>
      """

    afterRender: ->
      @skipLogicEditor = new $viewRowDetailSkipLogic.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), model: @model)
      @skipLogicEditor.builder = @model.builder
      @skipLogicEditor.render()
    insertInDOM: (rowView) ->
      rowView.cardSettingsWrap.find('.card__settings__fields--skip-logic').eq(0).append(@el)

  viewRowDetail.DetailViewMixins.constraint =
    html: ->
      @$el.addClass("card__settings__fields--active")
      # Validation logic (i.e. <span style='font-family:monospace'>constraint</span>):
      # <code>#{@model.get("value")}</code>
      fldUid = _.uniqueId("row-detail-field")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">Validation logic: </label>
        <span class="settings__input">
          <input type="text" name="#{@model.key}" id="#{@cid}" />
        </span>
      </div>
      """
    afterRender: ->
      @listenForInputChange()
    insertInDOM: (rowView) ->
      rowView.cardSettingsWrap.find('.card__settings__fields--validation-criteria').append(@el)

  viewRowDetail.DetailViewMixins.name =
    html: ->
      @fieldTab = "active"
      # @listenTo @model, "change:value", ()=>
      #   @render()
      #   @afterRender()
      @$el.addClass("card__settings__fields--#{@fieldTab}")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">#{@model.key}: </label>
        <span class="settings__input">
          <input type="text" name="#{@model.key}" id="#{@cid}" class="text" />
        </span>
      </div>
      """
    afterRender: ->
      @listenForInputChange(transformFn: (value)=>
        value_chars = value.split('')
        if !/[\w_]/.test(value_chars[0])
          value_chars.unshift('_')

        @model.set 'value', value
        @model.deduplicate @model.getSurvey()
      )
      update_view = () => @$el.find('input').eq(0).val(@model.get("value") || $modelUtils.sluggifyLabel @model._parent.getValue('label'))
      update_view()

      @model._parent.get('label').on 'change:value', update_view
  # insertInDom: (rowView)->
    #   # default behavior...
    #   rowView.defaultRowDetailParent.append(@el)

  viewRowDetail.DetailViewMixins.default =
    html: ->
      @fieldTab = "active"
      # @listenTo @model, "change:value", ()=>
      #   @render()
      #   @afterRender()
      @$el.addClass("card__settings__fields--#{@fieldTab}")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">#{@model.key}: </label>
        <span class="settings__input">
          <input type="text" name="#{@model.key}" id="#{@cid}" class="text" />
        </span>
      </div>
      """
    afterRender: ->
      @$el.find('input').eq(0).val(@model.get("value"))
      @listenForInputChange()

    # insertInDom: (rowView)->
    #   # default behavior...
    #   rowView.defaultRowDetailParent.append(@el)

  viewRowDetail.DetailViewMixins.calculation =
    html: -> false
    insertInDOM: (rowView)-> ``

  viewRowDetail.DetailViewMixins._isRepeat =
    html: ->
      @$el.addClass("card__settings__fields--active")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">Repeat: </label>
        <span class="settings__input">
          <input type="checkbox" name="#{@model.key}" id="#{@cid}"/> <label for="#{@cid}">Yes</label>
        </span>
      </div>
      """
    afterRender: ->
      @listenForCheckboxChange()

  viewRowDetail.DetailViewMixins.required =
    html: ->
      @$el.addClass("card__settings__fields--active")
      """
      <div class="card__settings__fields__field">
        <label for="#{@cid}">Required: </label>
        <span class="settings__input">
          <input type="checkbox" name="#{@model.key}" id="#{@cid}"/> <label for="#{@cid}">Yes</label>
        </span>
      </div>
      """
    afterRender: ->
      @listenForCheckboxChange()

      # inp = @$el.find("input")
      # # to be moved into the model when XLF.configs.truthyValues is refactored
      # isTrueValue = (@model.get("value") || "").toLowerCase() in $configs.truthyValues
      # inp.prop("checked", isTrueValue)
      # inp.change ()=> @model.set("value", inp.prop("checked"))

  viewRowDetail.DetailViewMixins.appearance =
    html: ->
      @$el.addClass("card__settings__fields--active")
      if @model._parent.constructor.key == 'group'
        """
        <div class="card__settings__fields__field">
          <label for="#{@cid}">Appearance: </label>
          <span class="settings__input">
            <input type="checkbox" name="#{@model.key}" id="#{@cid}"/><label for="#{@cid}">Show all questions in this groups on the same screen</label>
          </span>
        </div>
        """
      else
        """
        <div class="card__settings__fields__field">
          <label for="#{@cid}">#{@model.key}: </label>
          <span class="settings__input">
            <input type="text" name="#{@model.key}" id="#{@cid}" class="text" />
          </span>
        </div>
        """
    afterRender: ->
      if @model._parent.constructor.key == 'group'
        $checkbox = @$('input[type=checkbox]').eq(0)
        $checkbox.on 'change', () =>
          if $checkbox.prop('checked')
            @model.set('value', 'field-list')
          else
            @model.set('value', '')
      else
        @listenForInputChange()

  viewRowDetail
