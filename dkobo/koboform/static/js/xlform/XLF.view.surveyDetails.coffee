###
This is the view for the survey-wide details that appear at the bottom
of the survey. Examples: "imei", "start", "end"
###
class XLF.SurveyDetailView extends Backbone.View
  className: "survey-header__option"
  events:
    "change input": "changeChkValue"
  initialize: ({@model})->
  render: ()->
    @$el.append viewTemplates.xlfSurveyDetailView @model
    @chk = @$el.find("input")
    @chk.prop "checked", true  if @model.get "value"
    @changeChkValue()
    @
  changeChkValue: ()->
    if @chk.prop("checked")
      @$el.addClass("active")
      @model.set("value", true)
    else
      @$el.removeClass("active")
      @model.set("value", false)
