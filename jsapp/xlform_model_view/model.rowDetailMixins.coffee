define 'cs!xlform/model.rowDetailMixins', [
        'cs!xlform/mv.skipLogicHelpers',
        'xlform/model.rowDetails.skipLogic',
        'cs!xlform/view.rowDetail.SkipLogic',
        'cs!xlform/model.utils',
        ], (
            $skipLogicHelpers,
            $modelRowDetailsSkipLogic,
            $viewRowDetailSkipLogic,
            $modelUtils
            )->
  # To be extended ontop of a RowDetail when the key matches
  # the attribute in XLF.RowDetailMixin
  SkipLogicDetailMixin =
    getValue: ()->
      @serialize()

    postInitialize: ()->
      # TODO: get skip logic factories connected
      model_factory = new $modelRowDetailsSkipLogic.SkipLogicFactory @getSurvey()
      view_factory = new $viewRowDetailSkipLogic.SkipLogicViewFactory @getSurvey()
      survey = @getSurvey()
      current_question = @_parent

      @builder = new $skipLogicHelpers.SkipLogicBuilder model_factory, view_factory, survey, current_question, new $skipLogicHelpers.SkipLogicHelperFactory view_factory

    serialize: ()->
      # @hidden = false
      # note: reimplement "hidden" if response is invalid
      if @facade?
        @facade.serialize()
      else
        @builder.build().serialize()

    parse: ()->

    linkUp: ->


  rowDetailMixins =
    relevant: SkipLogicDetailMixin
    label:
      postInitialize: ()->
        # When the row's name changes, trigger the row's [finalize] function.
        ``

    name:
      deduplicate: (survey) ->
        names = []
        survey.forEachRow (r)=>
          if r.get('name') != @
            name = r.getValue("name")
            names.push(name)
        , includeGroups: true

        $modelUtils.sluggifyLabel @get('value'), names
  rowDetailMixins
