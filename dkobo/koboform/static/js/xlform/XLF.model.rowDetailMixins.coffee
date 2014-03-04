# To be extended ontop of a RowDetail when the key matches
# the attribute in XLF.RowDetailMixin
SkipLogicDetailMixin =
  getValue: ()->
    @serialize()

  postInitialize: ()->
    model_factory = new XLF.Model.SkipLogicFactory
    view_factory = new XLF.Views.SkipLogicViewFactory
    survey = @getSurvey()
    current_question = @_parent

    @builder = new XLF.SkipLogicBuilder model_factory, view_factory, survey, current_question

  serialize: ()->
    # @hidden = false
    # note: reimplement "hidden" if response is invalid
    @facade?.serialize()

  parse: ()->

  linkUp: ->


@XLF.RowDetailMixins =
  relevant: SkipLogicDetailMixin
  label:
    postInitialize: ()->
      # When the row's name changes, trigger the row's [finalize] function.
      @on "change:value", => @_parent.finalize()
      ``
