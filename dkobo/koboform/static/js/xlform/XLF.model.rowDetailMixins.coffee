# To be extended ontop of a RowDetail when the key matches
# the attribute in XLF.RowDetailMixin
SkipLogicDetailMixin =
  getValue: ()->
    @serialize()

  postInitialize: ()->
    model_factory = new XLF.Model.SkipLogicFactory @getSurvey()
    view_factory = new XLF.Views.SkipLogicViewFactory @getSurvey()
    survey = @getSurvey()
    current_question = @_parent

    @builder = new XLF.SkipLogicBuilder model_factory, view_factory, survey, current_question, new XLF.SkipLogicHelperFactory view_factory

  serialize: ()->
    # @hidden = false
    # note: reimplement "hidden" if response is invalid
    if @facade?
      @facade.serialize()
    else
      @builder.build().serialize()

  parse: ()->

  linkUp: ->


@XLF.RowDetailMixins =
  relevant: SkipLogicDetailMixin
  label:
    postInitialize: ()->
      # When the row's name changes, trigger the row's [finalize] function.
      @on "change:value", => @_parent.finalize()
      ``
