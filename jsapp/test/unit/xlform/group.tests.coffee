define [
        'cs!xlform/model.aliases',
        'cs!xlform/model.survey',
        'cs!test/fixtures/surveys',
        ], (
            $aliases,
            $survey,
            $surveys,
            )->

  describe 'group.tests', ->
    _firstGroup = (s)->
      _.first s.rows.filter (r,i)-> r.constructor.name is "Group"
    _lastGroup = (s)->
      _.last s.rows.filter (r,i)-> r.constructor.name is "Group"

    describe 'survey imports groups >', ->
      beforeEach ->
        @survey = $survey.Survey.load("""
        survey,,,
        ,type,name,label
        ,begin group,grp1,Group1
        ,text,g1q1,Group1Question1
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
      describe 'groups can be exported >', ->
        it 'works with a simple group', ->
          expect(@survey.toCSV().split('\n').length).toBe(8)
        it 'works with a nested group', ->
          survey = $survey.Survey.load("""
          survey,,,
          ,type,name,label
          ,begin group,grp1,Group1
          ,text,g1q1,Group1Question1
          ,begin group,grp2,Group2
          ,text,g1g2q1,Grp2Question1
          ,end group,,,
          ,end group,,,
          """)
          expect(survey.toCSV().split('\n').length).toBe(11)

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

    describe 'group creation', ->
      beforeEach ->
        @survey = $survey.Survey.load("""
        survey,,,
        ,type,name,label
        ,text,q1,Q1
        ,text,q2,Q2
        ,text,q3,Q3
        ,text,q4,Q4
        ,text,q5,Q5
        """)
      describe 'can create group with existing rows', ->
        beforeEach ->
          @getNames = (s)->
            _n = 'noname'
            names = []
            s.forEachRow (
                    (r)->
                      name = r.get('name')?.get('value') or _n
                      names.push name
                  ), includeGroups: true
            names

          expect(@survey._allRows().length).toBe(5)
          rows = for n in [0,2,4]
            @survey.rows.at(n)

          @survey._addGroup(label: 'My Group', __rows: rows)

        it 'and has the right number of rows', ->
          expect(@survey._allRows().length).toBe(5)
        it 'has the right order of names', ->
          @survey.finalize()
          expect(@getNames(@survey)).toEqual(["My_Group", "q1", "q3", "q5", "q2", "q4"])

        describe 'can generate missing names on finalize', ->
          beforeEach ->
            @grp = _firstGroup(@survey)

          it 'and has a finalize method', ->
            expect(@grp.finalize).toBeDefined()
          it 'and has finalize called on survey finalize', ->
            spyOn @grp, 'finalize'
            @survey.finalize()
            expect(@grp.finalize).toHaveBeenCalled()
          it 'has the correct name', ->
            @survey.finalize()
            expect(@getNames(@survey)).toEqual(['My_Group', 'q1', 'q3', 'q5', 'q2', 'q4'])

    describe 'group manipulation', ->
      beforeEach ->
        @survey = $survey.Survey.load("""
        survey,,,
        ,type,name,label
        ,text,q1,Q1
        ,begin group,grp1,Group1
        ,text,g1q1,G1Q1
        ,end group,,,
        ,text,q2,Q2
        """)
        @g1 = _firstGroup @survey

        @getNames = (s)->
          _n = 'noname'
          names = []
          s.forEachRow (
                  (r)->
                    name = r.get('name')?.get('value') or _n
                    names.push name
                ), includeGroups: true
          names
      it 'group can be deleted', ->
        g1 = _firstGroup @survey
        expect(@survey._allRows().length).toBe(3)
        @survey.remove g1
        expect(@survey._allRows().length).toBe(2)
      it 'group can be detached from parent', ->
        expect(@getNames(@survey)).toEqual(['q1', 'grp1', 'g1q1', 'q2'])
        @g1.detach()
        expect(@getNames(@survey)).toEqual(['q1', 'q2'])
      it 'group can be split apart', ->
        expect(@getNames(@survey)).toEqual(['q1', 'grp1', 'g1q1', 'q2'])
        @g1.splitApart()
        expect(@getNames(@survey)).toEqual(['q1', 'g1q1', 'q2'])
