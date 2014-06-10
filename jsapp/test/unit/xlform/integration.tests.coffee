# test end-to-end of the system
define [
        'cs!xlform/_view',
        'cs!xlform/_model',
        'cs!test/fixtures/surveys',
        ], (
            $view,
            $model,
            $surveys,
            )->

  describe 'integration.tests; necessary plugins are installed', ->
    it 'has select2', ->
      expect(jQuery.fn.select2).toBeDefined()

  describe 'integration.tests; integration of SurveyApp', ->
    beforeEach ->
      @load_csv = (scsv)=>
        @div.remove()  if @div
        @survey = $model.Survey.load(scsv)
        @div = $('<div>', class: 'test-div')
        @div.prependTo('body')
        @app = new $view.SurveyApp({survey: @survey, ngScope: {}})
        @div.append @app.$el
        @app.render()
      @ensure_selectrow = (el, classname='js-select-row--force', attachToClassname='js-select-row')->
        $el = $(el)
        $el.find(".#{attachToClassname}").eq(0).addClass(classname)
        $el.find(".#{classname}").eq(0)
      @viewedNames = =>
        names = []
        surv = @survey
        @div.find('.survey__row').each ->
          names.push surv.findRowByCid($(@).data('rowId')).get('name').get('value')
        names
      @surveyNames = ->
        names = []
        getName = (r)-> names.push r.get('name').get('value')
        @survey.forEachRow(getName, includeGroups: true)
        names

      @load_csv("""
        survey,,,
        ,type,name,label
        ,text,q1,Question1
        ,begin group,grp,
        ,text,g1q1,Group1Question1
        ,text,g1q2,Group1Question2
        ,end group,,
        """)
    afterEach -> $('.test-div').remove()

    it 'has group html structure', ->
      expect(@survey.rows.length).toBe(2)
      ul = @div.find('.survey-editor__list').eq(0)
      expect(ul.find('> .survey__row').length).toBe(2)
      survey__row__item_group = ul.find('> .survey__row').eq(1)
      group__rows = survey__row__item_group.find('.group__rows')
      expect(group__rows.find('> .survey__row').length).toBe(2)

    it 'has selectable rows', ->
      rowItems = @div.find('.survey-editor__list > .survey__row')
      row1 = rowItems.eq(0)
      jsSelectRow1 = @ensure_selectrow(row1)

      expect(@app.selectedRows().length).toBe(0)
      jsSelectRow1.click()
      expect(@app.selectedRows().length).toBe(1)
      expect(@div.find('.survey-editor__list > .survey__row').length).toBe(2)

    it 'has selectable groups', ->
      @load_csv """
      survey,,,
      ,type,name,label
      ,begin group,grp,Group1
      ,text,q1,Q1
      ,end group
      """
      expect(@div.find('.survey__row--selected').length).toBe(0)
      jsSelectRow1 = @ensure_selectrow(@div)
      jsSelectRow1.click()
      expect(@div.find('.survey__row--selected').length).toBe(1)
    describe 'row reordering', ->
      describe 'basic rows', ->
        beforeEach ->
          @load_csv """
          survey,,,
          ,type,name,label
          ,text,qa,QuestionA
          ,text,qb,QuestionB
          ,text,qc,QuestionC
          """

        it 'can switch ABC -> ACB', ->
          surv = @app.survey
          expect(@viewedNames()).toEqual(['qa','qb','qc'])
          expect(@surveyNames()).toEqual(['qa','qb','qc'])
          [$a, $b, $c] = ($(x)  for x in @div.find('.survey__row'))

          $a.after $c.detach()

          [prev, par] = @app._getRelatedElIds($c)
          expect(par).not.toBeDefined()
          expect(prev).toBe($a.data('rowId'))

          $c.trigger('survey__row-sortablestop', $c.data('rowId'))

          expect(@viewedNames()).toEqual(['qa','qc','qb'])
          expect(@surveyNames()).toEqual(['qa','qc','qb'])

    describe 'grouping selected rows', ->
      beforeEach ->
        @load_csv """
        survey,,,
        ,type,name,label
        ,text,q1,Question1
        ,begin group,grp,
        ,text,g1q1,Group1Question1
        ,text,g1q2,Group1Question2
        ,end group,,
        ,text,q2,Question2
        ,text,q3,Question3
        ,text,q4,Question4
        """

      it 'can group all rows and groups together', ->
        firstLevelRows = @div.find('.survey-editor__list > .survey__row')
        expect(firstLevelRows.length).toBe(5)
        firstLevelRows.addClass('survey__row--selected')
        expect(@app.selectedRows().length).toBe(5)

        # set the btn-disabled on btn--group-questions
        @app.questionSelect()
        expect(@div.find('.btn--group-questions').hasClass('btn--disabled')).not.toBeTruthy()

        @app.groupSelectedRows()
        expect(@app.survey.rows.at(0).getValue('type')).toBe('group')
        expect(@div.find('.survey-editor__list > .survey__row--group').length).toBe(1)

        # reset the btn-disabled on btn--group-questions
        @app.questionSelect()
        expect(@div.find('.btn--group-questions').hasClass('btn--disabled')).toBeTruthy()

        @div.find('.survey-editor__list > .survey__row--group').addClass('survey__row--selected')
        @app.questionSelect()
        expect(@div.find('.survey-editor__list > .survey__row--group').length).toBe(1)
        expect(@div.find('.survey-editor__list > .survey__row').length).toBe(1)

      # it 'places group at the correct part of the survey', ->
      #   @app.$el.find('.survey__row').eq(0).addClass('survey__row--selected')
      #   @app.groupSelectedRows()
      #   newGroupCid = @app.survey.rows.at(0).cid
      #   expect(@app.$el.find('.survey__row').eq(0).data('rowId')).toBe(newGroupCid)

      it 'can group discontinuous questions', ->
        firstLevelRows = @div.find('.survey-editor__list > .survey__row')
        firstLevelRows.eq(0).addClass('survey__row--selected')
        firstLevelRows.eq(-1).addClass('survey__row--selected')
        expect(@app.selectedRows().length).toBe(2)
        @app.groupSelectedRows()
        # dump @survey.toCSV()
