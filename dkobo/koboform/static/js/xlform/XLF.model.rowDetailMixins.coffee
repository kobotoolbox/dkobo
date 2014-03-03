# To be extended ontop of a RowDetail when the key matches
# the attribute in XLF.RowDetailMixin
SkipLogicDetailMixin =
  getValue: ()->
    @serialize()

  postInitialize: ()->
    @skipLogicCollection = new XLF.SkipLogicCollection([], rowDetail: @)

    model_factory = new XLF.Model.SkipLogicFactory
    view_factory = new XLF.Views.SkipLogicViewFactory
    survey = @getSurvey()
    current_question = @_parent

    @builder = new XLF.SkipLogicBuilder model_factory, view_factory, survey, current_question

    @parse()
    if !@skipLogicCollection.parseable and @get('value') != ''
      @skipLogicCollection.add(new XLF.HandCodedSkipLogicCriterion(@get('value')))
      @skipLogicCollection.meta.set('mode', 'handcode')

  serialize: ()->
    # @hidden = false
    # note: reimplement "hidden" if response is invalid
    @facade?.serialize()

  parse: ()->
    XLF.parseHelper.parseSkipLogic(@skipLogicCollection, @get('value'), @_parent)

  linkUp: ->
    @skipLogicCollection.each (i)-> i.linkUp()

@XLF.RowDetailMixins =
  relevant: SkipLogicDetailMixin
  label:
    postInitialize: ()->
      # When the row's name changes, trigger the row's [finalize] function.
      @on "change:value", => @_parent.finalize()
      ``
