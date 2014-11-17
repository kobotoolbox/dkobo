define 'cs!xlform/view.rowDetail.ValidationLogic', [
  'cs!xlform/view.rowDetail.SkipLogic'
], ($skipLogicView) ->

  viewRowDetailValidationLogic = {}
  class viewRowDetailValidationLogic.ValidationLogicViewFactory extends $skipLogicView.SkipLogicViewFactory
    create_criterion_builder_view: () ->
      return new viewRowDetailValidationLogic.ValidationLogicCriterionBuilder()
    create_question_picker: () ->
      return new viewRowDetailValidationLogic.ValidationLogicQuestionPicker

  class viewRowDetailValidationLogic.ValidationLogicCriterionBuilder extends $skipLogicView.SkipLogicCriterionBuilderView
    render: () ->
      super
      @$el.html(@$el.html().replace 'only be displayed', 'be valid only')

      @

  class viewRowDetailValidationLogic.ValidationLogicQuestionPicker extends $skipLogicView.Base
    tagName: 'span'
    render: () ->
      @$el.text("This question's response has to be")
    fill_value: () ->
    bind_event: () ->
    attach_to: (target) ->
      target.find('.skiplogic__rowselect').remove()
      super(target)

  viewRowDetailValidationLogic