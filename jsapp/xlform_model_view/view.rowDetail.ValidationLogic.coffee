define 'cs!xlform/view.rowDetail.ValidationLogic', [
  'cs!xlform/view.rowDetail.SkipLogic'
], ($skipLogicView) ->

  viewRowDetailValidationLogic = {}
  class viewRowDetailValidationLogic.ValidationLogicViewFactory extends $skipLogicView.SkipLogicViewFactory
    create_criterion_builder_view: () ->
      return new viewRowDetailValidationLogic.ValidationLogicCriterionBuilder()

  class viewRowDetailValidationLogic.ValidationLogicCriterionBuilder extends $skipLogicView.SkipLogicCriterionBuilderView
    render: () ->
      super
      @$el.html(@$el.html().replace 'only be displayed', 'be valid only')

      @

  viewRowDetailValidationLogic