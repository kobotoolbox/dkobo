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
      rows: 3

DetailViewMixins.hint =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

class XLF.SkipLogicView extends Backbone.View
  initialize: (opts) ->
    @relevantDetailView = opts.relevantDetailView
    #@model = @relevantDetailView.model
  render: () ->
    @$el.html('<select></select> was <input placeholder="response value" type="text" />')
    select = @$el.find('select')
    input = @$el.find('input')
    survey = @model.parent.getSurvey()
    surveyNames = survey.getNames()

    $("<option>", {value: '-1', html: 'Question...'}).appendTo(select)
    
    for name in surveyNames
      $("<option>", {value: name, html: name, disabled: name is @model.parent.parentRow.get('name').get('value')}).appendTo(select)

    wireUpInput(select, @model, 'questionName')

    wireUpInput(input, @model, 'criterion')

    disableDefaultOption = () -> 
      $('option[value=-1]', select).prop('disabled', true)
      select.off('change', disableDefaultOption)
    
    select.on('change', disableDefaultOption)
    
    @

wireUpInput = ($input, model, name) =>
  if model.get(name)
      $input.val(model.get(name))

  $input.on('change', () => model.set(name, $input.val()))
  ``

class XLF.SkipLogicClause extends Backbone.Model
  serialize: () ->
    if (@isValid())
      return "${" + @get('questionName') + "} = " + @get('criterion')

DetailViewMixins.relevant = 
  html: ->
    """
      Skip logic (i.e. <span style='font-family:monospace'>relevant</span>):
      <code>#{@model.get("value")}</code>
    """

    """
      <button>Skip Logic</button>
    """

  afterRender: ->
    button = @$el.find("button")
    button.click () =>
      @skipLogicClause = new XLF.SkipLogicClause()
      @skipLogicClause.parent = @model
      @model.parentRow.skipLogicClause = @skipLogicClause

      new XLF.SkipLogicView(relevantDetailView: @, model: @skipLogicClause).render().$el.appendTo(@$el)
      button.off('click')

    viewUtils.makeEditable @, @model, 'code', {}

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