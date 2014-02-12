class XLF.Group extends XLF.SurveyFragment
  initialize: ()->
    @set "type", {value: "begin group"}
  groupStart: ->
    toJSON: => @attributes
    inGroupStart: true
  groupEnd: ->
    toJSON: ()-> type: "end group"
