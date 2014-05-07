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
      "click .rowselector_openlibrary": "openLibrary"
    initialize: (opts)->
      @options = opts
      @ngScope = opts.ngScope
      @button = @$el.find(".btn")
      @line = @$el.find(".line")
      if opts.action is "click-add-row"
        @expand()
    expand: ->
      @button.fadeOut 150
      @line.addClass "expanded"
      @line.parents(".survey-editor__null-top-row").addClass "expanded"
      @line.css "height", "inherit"
      @line.html $viewTemplates.$$render('xlfRowSelector.line')
      $menu = @line.find(".rowselector__questiontypes")
      $menu.on("click", ".menu-item", _.bind(@selectMenuItem, @))
      for mrow in $icons.grouped()
        menurow = $("<div>", class: "menu-row").appendTo $menu
        for mitem, i in mrow
          menurow.append $viewTemplates.$$render('xlfRowSelector.cell', mitem.attributes)

    shrink: ->
      # click .js-close-row-selector
      @line.find("div").eq(0).fadeOut 250, =>
        @line.empty()
      @line.parents(".survey-editor__null-top-row").removeClass "expanded"
      @button.fadeIn 200
      @line.removeClass "expanded"
      @line.animate height: "0"
    hide: ->
      @button.show()
      @line.empty().removeClass("expanded").css "height": 0

    openLibrary: ()->
      @ngScope.displayQlib = true
      @ngScope.$apply()
      model = @options.spawnedFromView?.model
      rowIndex = if model then model.collection.indexOf(model) else -1

      $("section.koboform__questionlibrary").data("rowIndex", rowIndex)
      ``

    selectMenuItem: (evt)->
      $('select.skiplogic__rowselect').select2('destroy')
      mi = $(evt.target).data("menuItem")
      rowBefore = @options.spawnedFromView?.model
      survey = @options.survey || rowBefore.getSurvey()
      rowBeforeIndex = survey.rows.indexOf(rowBefore)
      survey.addRowAtIndex({type: mi}, rowBeforeIndex+1)
      @hide()

  viewRowSelector
