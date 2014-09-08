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
      survey = @getSurvey()
      model_factory = new $modelRowDetailsSkipLogic.SkipLogicFactory survey
      view_factory = new $viewRowDetailSkipLogic.SkipLogicViewFactory survey
      helper_factory = new $skipLogicHelpers.SkipLogicHelperFactory model_factory, view_factory, survey, @_parent

      @facade = new $skipLogicHelpers.SkipLogicPresentationFacade model_factory, helper_factory, view_factory

    serialize: ()->
      # @hidden = false
      # note: reimplement "hidden" if response is invalid
      @facade.serialize()

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
