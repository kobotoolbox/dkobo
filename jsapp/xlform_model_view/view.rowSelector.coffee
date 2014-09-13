define 'cs!xlform/view.rowSelector', [
        'backbone',
        'cs!xlform/view.pluggedIn.backboneView',
        'cs!xlform/view.templates',
        'cs!xlform/view.icons',
        ], (
            Backbone,
            $baseView,
            $viewTemplates,
            $icons,
            )->

  viewRowSelector = {}

  class viewRowSelector.RowSelector extends $baseView
    events:
      "click .js-close-row-selector": "shrink"
    initialize: (opts)->
      @options = opts
      @ngScope = opts.ngScope
      @reversible = opts.reversible
      @button = @$el.find(".btn").eq(0)
      @line = @$el.find(".line")
      if opts.action is "click-add-row"
        @expand()

    expand: ->
      @show_namer()
      $namer_form = @$el.find('.row__questiontypes__form')
      $namer_form.on 'submit', _.bind @show_picker, @
      $namer_form.find('button').on 'click', (evt) ->
        evt.preventDefault()
        $namer_form.submit()
      @$('input').eq(0).focus()

    show_namer: () ->
      $surveyViewEl = @options.surveyView.$el
      $surveyViewEl.find('.line.expanded').removeClass('expanded').empty()
      $surveyViewEl.find('.btn--hidden').removeClass('btn--hidden')

      @button.addClass('btn--hidden')

      @line.addClass "expanded"
      @line.parents(".survey-editor__null-top-row").addClass "expanded"
      @line.css "height", "inherit"
      @line.html $viewTemplates.$$render('xlfRowSelector.namer')
      $.scrollTo @line, 200, offset: -300
      $(window).on 'keydown.cancel_add_question',  (evt) =>
        if evt.which == 27
          @hide()

      $('body').on 'mousedown.cancel_add_question', (evt) =>
        if $(evt.target).closest('.line.expanded').length == 0
          @hide()

    show_picker: (evt) ->
      evt.preventDefault()
      @question_name = @line.find('input').val()
      @line.empty()
      $.scrollTo @line, 200, offset: -300

      @line.html $viewTemplates.$$render('xlfRowSelector.line', "")
      @line.find('.row__questiontypes__new-question-name').val(@question_name)
      $menu = @line.find(".row__questiontypes__list")
      for mrow in $icons.grouped()
        menurow = $("<div>", class: "questiontypelist__row").appendTo $menu
        for mitem, i in mrow
          menurow.append $viewTemplates.$$render('xlfRowSelector.cell', mitem.attributes)
      @$('.questiontypelist__item').click _.bind(@selectMenuItem, @)

    shrink: ->
      # click .js-close-row-selector
      @line.find("div").eq(0).fadeOut 250, =>
        @line.empty()
      @line.parents(".survey-editor__null-top-row").removeClass "expanded"
      @line.removeClass "expanded"
      @line.animate height: "0"
      if @reversible
        @button.removeClass('btn--hidden')
    hide: ->
      @button.removeClass('btn--hidden')
      @line.empty().removeClass("expanded").css "height": 0
      $(window).off 'keydown.cancel_add_question'
      $('body').off 'mousedown.cancel_add_question'
      @line.parents(".survey-editor__null-top-row").removeClass "expanded"

    selectMenuItem: (evt)->
      @question_name = @line.find('input').val()
      $('select.skiplogic__rowselect').select2('destroy')
      rowType = $(evt.target).closest('.questiontypelist__item').data("menuItem")
      value = @question_name || 'New Question'

      rowDetails =
        type: rowType

      if rowType is 'calculate'
        rowDetails.calculation = value
      else
        rowDetails.label = value

      options = {}
      if (rowBefore = @options.spawnedFromView?.model)
        options.after = rowBefore
        survey = rowBefore.getSurvey()
      else
        options.at = 0
        survey = @options.survey

      survey.addRow(rowDetails, options)
      @hide()
      @options.surveyView.reset()

  viewRowSelector
