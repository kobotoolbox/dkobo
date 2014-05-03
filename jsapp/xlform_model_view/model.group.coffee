define ["cs!xlform/model.surveyFragment"], (base)->

  class Group extends surveyFragment.SurveyFragment
    initialize: ()->
      @set "type", {value: "begin group"}
    groupStart: ->
      toJSON: => @attributes
      inGroupStart: true
    groupEnd: ->
      toJSON: ()-> type: "end group"

  Group: Group
