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
      "submit .row__questiontypes__form": "show_picker"
      "click .questiontypelist__item": "selectMenuItem"
    initialize: (opts)->
      @options = opts
      @ngScope = opts.ngScope
      @reversible = opts.reversible
      @button = @$el.find(".btn").eq(0)
      @line = @$el.find(".line")
      if opts.action is "click-add-row"
        @expand()
      if !@reversible
        @button.hide()

    expand: ->
      @show_namer()
      @$('input').eq(0).focus()

    show_namer: () ->
      $('.line').empty()

      @line.addClass "expanded"
      @line.parents(".survey-editor__null-top-row").addClass "expanded"
      @line.css "height", "inherit"
      @line.html $viewTemplates.$$render('xlfRowSelector.namer')
      $.scrollTo @line, 200, offset: -300

    show_picker: (evt) ->
      evt.preventDefault()
      @question_name = @line.find('input').val()
      @line.empty()
      $.scrollTo @line, 200, offset: -300
      @line.html $viewTemplates.$$render('xlfRowSelector.line', @question_name)
      $menu = @line.find(".row__questiontypes__list")
      for mrow in $icons.grouped()
        menurow = $("<div>", class: "questiontypelist__row").appendTo $menu
        for mitem, i in mrow
          menurow.append $viewTemplates.$$render('xlfRowSelector.cell', mitem.attributes)

    shrink: ->
      # click .js-close-row-selector
      @line.find("div").eq(0).fadeOut 250, =>
        @line.empty()
      @line.parents(".survey-editor__null-top-row").removeClass "expanded"
      @line.removeClass "expanded"
      @line.animate height: "0"
    hide: ->
      @button.show()
      @line.empty().removeClass("expanded").css "height": 0

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
        survey = @options.survey

      survey.addRow(rowDetails, options)
      @hide()
      @options.surveyView.reset()

  viewRowSelector
