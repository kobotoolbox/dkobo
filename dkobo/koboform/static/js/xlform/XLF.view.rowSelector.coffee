class XLF.RowSelector extends Backbone.View
  events:
    "click .js-close-row-selector": "shrink"
    "click .rowselector_openlibrary": "openLibrary"
  initialize: (opts)->
    @options = opts
    @button = @$el.find(".btn")
    @line = @$el.find(".line")
    if opts.action is "click-add-row"
      @expand()
  expand: ->
    $(".-form-editor .empty .survey-editor__message").css("display", "none")
    @button.fadeOut 150
    @line.addClass "expanded"
    @line.css "height", "inherit"
    @line.html viewTemplates.xlfRowSelector.line()
    $menu = @line.find(".rowselector__questiontypes")
    $menu.on("click", ".menu-item", _.bind(@selectMenuItem, @))
    for mrow in XLF.icons.grouped()
      menurow = $("<div>", class: "menu-row").appendTo $menu
      for mitem, i in mrow
        menurow.append viewTemplates.xlfRowSelector.cell mitem.attributes

  shrink: ->
    # click .js-close-row-selector
    $(".-form-editor .empty .survey-editor__message").css("display", "")
    @line.find("div").eq(0).fadeOut 250, =>
      @line.empty()
    @button.fadeIn 200
    @line.removeClass "expanded"
    @line.animate height: "0"
  hide: ->
    @button.show()
    @line.empty().removeClass("expanded").css "height": 0

  openLibrary: ()->
    log "XLF.RowSelector::openLibrary()"
    $(".librarywrap").remove()
    # XLF.launchQuestionLibrary is in XLF.view.utils.coffee
    XLF.launchQuestionLibrary().addClass("librarywrap").appendTo("body")

  selectMenuItem: (evt)->
    $('select.skiplogic__rowselect').select2('destroy')
    mi = $(evt.target).data("menuItem")
    rowBefore = @options.spawnedFromView?.model
    survey = @options.survey || rowBefore.getSurvey()
    rowBeforeIndex = survey.rows.indexOf(rowBefore)
    survey.addRowAtIndex({type: mi}, rowBeforeIndex+1)
    @hide()
