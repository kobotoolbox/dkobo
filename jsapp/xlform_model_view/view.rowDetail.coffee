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
      _.extend(@, viewRowDetail.DetailViewMixins[@model.key] || viewRowDetail.DetailViewMixins.default)
      @$el.addClass(@extraClass)

    render: ()->
      rendered = @html()
      if rendered
        @$el.html rendered

      @afterRender && @afterRender()
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

    _insertInDOM: (where, how) ->
      where[how || 'append'](@el)
    insertInDOM: (rowView)->
      @_insertInDOM rowView.defaultRowDetailParent

  viewRowDetail.Templates = {
    textbox: (cid, key, key_label = key, input_class = '') ->
      @field """<input type="text" name="#{key}" id="#{cid}" class="#{input_class}" />""", cid, key_label

    checkbox: (cid, key, key_label = key, input_label = 'Yes') ->
      @field """<input type="checkbox" name="#{key}" id="#{cid}"/> <label for="#{cid}">#{input_label}</label>""", cid, key_label

    field: (input, cid, key_label) ->
      """
      <div class="card__settings__fields__field">
        <label for="#{cid}">#{key_label}:</label>
        <span class="settings__input">
          #{input}
        </span>
      </div>
      """
  }

  viewRowDetail.DetailViewMixins = {}

  viewRowDetail.DetailViewMixins.type =
    html: -> false
    insertInDOM: (rowView)->
      typeStr = @model.get("typeId")
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
      viewRowDetail.Templates.textbox @cid, @model.key, @model.key, 'text'
    afterRender: ->
      @listenForInputChange()

  viewRowDetail.DetailViewMixins.constraint_message =
    html: ->
      @$el.addClass("card__settings__fields--active")
      viewRowDetail.Templates.textbox @cid, @model.key, 'Error Message', 'text'
    insertInDOM: (rowView)->
      @_insertInDOM rowView.cardSettingsWrap.find('.card__settings__fields--validation-criteria').eq(0)
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
      @$el.find(".relevant__editor").html("""
        <div class="skiplogic__main"></div>
        <p class="skiplogic__extras">
        </p>
      """)

      @target_element = @$('.skiplogic__main')

      @model.facade.render @target_element

    insertInDOM: (rowView) ->
      @_insertInDOM rowView.cardSettingsWrap.find('.card__settings__fields--skip-logic').eq(0)

  viewRowDetail.DetailViewMixins.constraint =
    html: ->
      @$el.addClass("card__settings__fields--active")
      viewRowDetail.Templates.textbox @cid, @model.key, 'Criteria'
    afterRender: ->
      @listenForInputChange()
    insertInDOM: (rowView) ->
      @_insertInDOM rowView.cardSettingsWrap.find('.card__settings__fields--validation-criteria')

  viewRowDetail.DetailViewMixins.name =
    html: ->
      @fieldTab = "active"
      @$el.addClass("card__settings__fields--#{@fieldTab}")
      viewRowDetail.Templates.textbox @cid, @model.key, @model.key, 'text'
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
      @$el.addClass("card__settings__fields--#{@fieldTab}")
      viewRowDetail.Templates.textbox @cid, @model.key, @model.key, 'text'
    afterRender: ->
      @$el.find('input').eq(0).val(@model.get("value"))
      @listenForInputChange()

  viewRowDetail.DetailViewMixins.calculation =
    html: -> false
    insertInDOM: (rowView)-> return

  viewRowDetail.DetailViewMixins._isRepeat =
    html: ->
      @$el.addClass("card__settings__fields--active")
      viewRowDetail.Templates.checkbox @cid, @model.key, 'Repeat', 'Repeat this group if necessary'
    afterRender: ->
      @listenForCheckboxChange()

  viewRowDetail.DetailViewMixins.required =
    html: ->
      @$el.addClass("card__settings__fields--active")
      viewRowDetail.Templates.checkbox @cid, @model.key, 'Required'
    afterRender: ->
      @listenForCheckboxChange()

  viewRowDetail.DetailViewMixins.appearance =
    html: ->
      @$el.addClass("card__settings__fields--active")
      if @model._parent.constructor.key == 'group'
        viewRowDetail.Templates.checkbox @cid, @model.key, 'Appearance', 'Show all questions in this group on the same screen'
      else
        viewRowDetail.Templates.textbox @cid, @model.key, 'Appearance', 'text'
    afterRender: ->
      if @model._parent.constructor.key == 'group'
        $checkbox = @$('input[type=checkbox]').eq(0)
        value_lookup = ['', 'field-list']
        $checkbox.on 'change', () =>
          @model.set('value', value_lookup[+$checkbox.prop('checked')])
      else
        @listenForInputChange()

  viewRowDetail
