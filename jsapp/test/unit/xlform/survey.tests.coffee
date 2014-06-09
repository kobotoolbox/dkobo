# test end-to-end of the system
define [
        'cs!xlform/_model',
        ], (
            $model,
            )->

  surveys = {}
  surveys.group = """
      survey,,,
      ,type,name,label
      ,text,q1,Question1
      ,begin group,grp,
      ,text,g1q1,Group1Question1
      ,text,g1q2,Group1Question2
      ,end group,,
      """
  surveys.iterateOver = """
      survey,,,
      ,type,name,label
      ,text,q1,Question1
      ,begin group,grp,
      ,text,g1q1,Group1Question1
      ,text,g1q2,Group1Question2
      ,end group,,
      ,text,q8,Question8
      ,text,q9,Question9
      ,err,err,err
      """
  surveys.singleQ = """
      survey,,,
      ,type,name,label
      ,text,q1,Question1
      """
  surveys.withChoices = """
      survey,,,
      ,type,name,label
      ,select_one yesno,yn,YesNo
      choices,,,
      ,list name,label,name
      ,yesno,Yes,yes
      ,yesno,No,no
      """
  describe 'survey.tests: Row types', ->
    beforeEach ->
      window.xlfHideWarnings = true
      @survey = new $model.Survey()
    afterEach -> window.xlfHideWarnings = false

    it 'has a valid empty survey', ->
      expect(@survey.toCSV()).toBeDefined()
    it 'can add rows to the survey', ->
      @survey.rows.add type: 'text', name: 'q1'
      expect(@survey.rows.at(0).toJSON().name).toBe('q1')
      @survey.rows.add type: '_errortype', name: 'q2'
      expect(@survey.rows.at(1).toJSON().type).toBe('_errortype')
      @survey.rows.add type: 'note', name: 'q3'
      expect(@survey.rows.at(2).toJSON().type).toBe('note')

  describe 'Survey load', ->
    beforeEach ->
      @load_csv = (scsv)=>
        @survey = $model.Survey.load(scsv)
      @expectKeysOf = (obj, keys)->
        expect (obj[key]  for key in keys)

    it 'loads a single question survey', ->
      @load_csv(surveys.singleQ)
      @expectKeysOf(@survey.toCsvJson().survey.rowObjects[0],
          ['type', 'name', 'label']).toEqual(['text', 'q1', 'Question1'])

    it 'loads a multiple choice survey', ->
      @load_csv(surveys.withChoices)
      expect(@survey.toJSON()).toEqual({
          'survey': [
            {
              'type': {'select_one': 'yesno'},
              'name': 'yn',
              'label': 'YesNo',
              'required': 'false'
            }
          ],
          'choices': {
            'yesno': [
              {
                'label': 'Yes',
                'name': 'yes'
              },
              {
                'label': 'No',
                'name': 'no'
              }
            ]
          }
        })
    describe 'survey row reordering', ->
      beforeEach ->
        @surveyNames = ->
          names = []
          getName = (r)-> names.push r.get('name').get('value')
          @survey.forEachRow(getName, includeGroups: true)
          names
      it 'can switch ABC -> ACB', ->
        @load_csv """
        survey,,,
        ,type,name,label
        ,text,qa,QuestionA
        ,text,qb,QuestionB
        ,text,qc,QuestionC
        """
        expect(@surveyNames()).toEqual(['qa', 'qb', 'qc'])
        [qa, qb, qc] = @survey.rows.models
        _parent = qa._parent
        @survey._insertRowInPlace(qc, previous: qa)
        expect(qc._parent).toBe(_parent)
        expect(@surveyNames()).toEqual(['qa', 'qc', 'qb'])

    describe 'forEachRow iterator tests', ->
      beforeEach ->
        window.xlfHideWarnings = true

        @load_csv surveys.iterateOver
        @getProp = (propName, arr)->
          (r)->
            arr.push r.get(propName)?.get('value')
      afterEach -> window.xlfHideWarnings = false

      it 'runs normally', ->
        # without any options, it will skip the group but iterate
        # through the rows of the group
        @survey.forEachRow @getProp('name', names = [])
        expect(names).toEqual('q1 g1q1 g1q2 q8 q9'.split(' '))

      it 'runs flat', ->
        # when flat:true option is passed, it will not iterate through
        # any nested groups
        options =
          flat: true

        @survey.forEachRow @getProp('name', names = []), options
        expect(names).toEqual('q1 q8 q9'.split(' '))

      it 'runs with includeGroups', ->
        # when includeGroups:true , it will include the group and the nested
        # values
        options =
          includeGroups: true

        @survey.forEachRow @getProp('name', names = []), options
        expect(names).toEqual('q1 grp g1q1 g1q2 q8 q9'.split(' '))

      it 'runs with includeGroups', ->
        # when includeGroups:true , it will include the group and the nested
        # values
        options =
          includeGroups: true

        @survey.forEachRow @getProp('name', names = []), options
        expect(names).toEqual('q1 grp g1q1 g1q2 q8 q9'.split(' '))

      it 'runs with includeErrors', ->
        # when includeErrors:true, it will include erroneous rows
        options =
          includeErrors: true

        @survey.forEachRow @getProp('name', names = []), options
        expect(names).toEqual('q1 g1q1 g1q2 q8 q9 err'.split(' '))


      # dump(@survey.toJSON(true))
      ###
      expect(@survey.toJSON()).toEqual({
          'survey': [
            {
              'type': {'select_one': 'yesno'},
              'name': 'yn',
              'label': 'YesNo',
              'required': 'false'
            }
          ],
          'choices': {
            'yesno': [
              {
                'label': 'Yes',
                'name': 'yes'
              },
              {
                'label': 'No',
                'name': 'no'
              }
            ]
          }
        })
      ###
