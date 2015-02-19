define 'cs!xlform/view.rowDetail.ValidationLogic', [
  'cs!xlform/view.rowDetail.SkipLogic',
  'cs!xlform/view.widgets'
], ($skipLogicView, $viewWidgets) ->

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

  class viewRowDetailValidationLogic.ValidationLogicQuestionPicker extends $viewWidgets.Label
    constructor: () ->
      super("This question's response has to be")
    attach_to: (target) ->
      target.find('.skiplogic__rowselect').remove()
      super(target)

  viewRowDetailValidationLogic