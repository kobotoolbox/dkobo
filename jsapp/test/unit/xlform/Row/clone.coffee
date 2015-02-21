define 'cs!test/unit/xlform/Row/clone', [
          'cs!xlform/_model',
          ], (
              $model,
              )->

  describe 'Row Cloning', () ->
    _row = null
    describe 'Select Type', () ->
      beforeEach ->
        survey = $model.Survey.load("""
          survey,,,
          ,type,name,label
          ,select_one yesno,yn,YesNo
          choices,,,
          ,list name,label,name
          ,yesno,Yes,yes
          ,yesno,No,no
          """)
        _row = survey.rows.at(0)
      it 'Clones select questions correctly', () ->
        newRow = _row.clone()
        expect(newRow.cid).not.toEqual _row.cid
        expect(newRow._parent).toBe _row._parent
        expect(newRow.get('type').get('typeId')).toBe 'select_one'
        expect(newRow.getValue('name')).toBe 'yn'
        expect(newRow.getValue('label')).toBe 'YesNo'

      it 'Creates unique ChoiceLists for cloned select questions', () ->
        clonedListStub = get: (key) -> if key == 'name' then 'stubbedList'
        choicelistStub =
          get: (key) -> if key == 'name' then 'originalList'
          clone: () -> clonedListStub
        _row.get('type').set 'list', choicelistStub

        newRow = _row.clone()

        expect(newRow.get('type').get('list')).toBe clonedListStub
        expect(newRow.get('type').get('listName')).toBe 'stubbedList'

    describe 'Other types', ->
      beforeEach ->
        survey = $model.Survey.load("""
          survey,,,
          ,type,name,label
          ,text,yn,YesNo
          """)
        _row = survey.rows.at(0)

      it 'doesn`t try to clone choicelists for rows not of  select type', ->
        newRow = _row.clone()
        expect(newRow.cid).not.toEqual _row.cid
        expect(newRow._parent).toBe _row._parent
        expect(newRow.get('type').get('typeId')).toBe 'text'
        expect(newRow.get('type').get('list')).toBeUndefined()
        expect(newRow.getValue('name')).toBe 'yn'
        expect(newRow.getValue('label')).toBe 'YesNo'
