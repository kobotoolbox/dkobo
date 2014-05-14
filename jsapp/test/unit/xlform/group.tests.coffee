define [
        'cs!xlform/model.aliases',
        'cs!xlform/model.survey',
        'cs!test/fixtures/surveys',
        ], (
            $aliases,
            $survey,
            $surveys,
            )->

  describe 'model.groups', ->
    _firstGroup = (s)->
      _.first s.rows.filter (r,i)-> r.constructor.name is "Group"
    _lastGroup = (s)->
      _.last s.rows.filter (r,i)-> r.constructor.name is "Group"

    describe 'survey imports groups', ->
      beforeEach ->
        @survey = $survey.Survey.load("""
        survey,,,
        ,type,name,label
        ,begin group,grp1,Group1
        ,text,q1,Question1
        ,end group,,,
        """)
      it 'can import a simple group', ->
        first_group = _firstGroup(@survey)
        expect(first_group).toBeDefined()
        expect(first_group.rows.length).toBe(1)
      it 'can add a group to the survey', ->
        @survey.addRow type: 'group', name: 'grp2'
        expect(@survey.rows.length).toBe(2)
        expect(_lastGroup(@survey).rows.length).toBe(0)
    it 'can import repeats', ->
      survey = $survey.Survey.load("""
      survey,,,
      ,type,name,label
      ,begin repeat,repeat1,Repeat1
      ,text,q1,Question1
      ,end repeat,,
      """)
      first_row = survey.rows.first()
      expect(first_row).toBeDefined()
      expect(first_row.constructor.name).toBe("Group")
      expect(first_row._isRepeat()).toBeTruthy()
    describe 'fails on unmatched group types', ->
      expectFailure = (msg, surv)->
        execFn = ->
          survey = $survey.Survey.load(surv)
        expect(execFn).toThrow()

      it 'fails with unclosed group', ->
        expectFailure 'unclosed', """
        survey,,,
        ,type,name,label
        ,begin group,grp1,Group1
        """
      it 'fails with mismatched group and repeat', ->
        expectFailure 'mismatch', """
        survey,,,
        ,type,name,label
        ,begin group,grp1,Group1
        ,end repeat,,
        """
      it 'fails with mismatched group and repeat', ->
        expectFailure 'mismatch', """
        survey,,,
        ,type,name,label
        ,begin repeat,grp1,Group1
        ,end group,,
        """
