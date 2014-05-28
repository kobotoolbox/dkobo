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

  describe 'necessary plugins are installed', ->
    it 'has select2', ->
      expect(jQuery.fn.select2).toBeDefined()


  describe 'integration of SurveyApp', ->
    beforeEach ->
      @survey = $model.Survey.load("""
      survey,,,
      ,type,name,label
      ,text,q1,Question1
      ,begin group,grp,
      ,text,g1q1,Group1Question1
      ,text,g1q2,Group1Question2
      ,end group,,
      """)
      @div = $('<div>', class: 'test-div')
      @div.prependTo('body')
      @app = new $view.SurveyApp({survey: @survey, ngScope: {}})
      @div.append @app.$el
      @app.render()

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
      if row1.find('.js-select-row').length is 0
        $('<span>', class: 'js-select-row', html: 'select row').appendTo(row1)
      jsSelectRow1 = row1.find('.js-select-row').eq(0)

      expect(@app.selectedRows().length).toBe(0)
      jsSelectRow1.click()
      expect(@app.selectedRows().length).toBe(1)
      expect(@div.find('.survey-editor__list > .survey__row').length).toBe(2)

    it 'can group rows', ->
      @survey.rows.add type: 'text', name: 'q3', label: 'Q3'
      @survey.rows.add type: 'text', name: 'q4', label: 'Q4'

      firstLevelRows = @div.find('.survey-editor__list > .survey__row')
      expect(firstLevelRows.length).toBe(4)
      firstLevelRows.addClass('survey__row--selected')
      expect(@app.selectedRows().length).toBe(4)
      @app.groupSelectedRows()
      dump(@survey.toCSV())
      

    afterEach ->
      $('.test-div').remove()
