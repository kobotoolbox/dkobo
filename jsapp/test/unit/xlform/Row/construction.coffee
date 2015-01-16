define 'cs!test/unit/xlform/Row/construction', [
          'cs!xlform/_model',
          'cs!xlform/model.configs',
          ], (
              $model,
              $configs,
              )->

  describe 'Row Construction', () ->
    it 'throws an error when question type is missing', () ->
      expect(() -> new $model.Row(label: 'passed label', name: 'passed name')).toThrow 'missing type'
    it 'throws an error when label attribute is missing and no language labels are passed', () ->
      expect(() -> new $model.Row(type: 'text', name: 'passed name', hint: 'passed hint')).toThrow 'missing type'

    describe 'Initialize Method', () ->

      _oldNewRowDetails = null
      beforeEach () ->
        _oldNewRowDetails = $configs.newRowDetails

        $configs.newRowDetails =
          name: value: 'test',
          label: value: 'test',
          type: value: 'test',
          hint: value: 'test',
          required: value: 'test',
          relevant: value: 'test'

      afterEach () ->
        $configs.newRowDetails = _oldNewRowDetails

      it 'uses default attributes when only type is passed in', () ->
        row = new $model.Row(type: 'text')
        row.initialize()

        dump row.toJSON()
        expect(row.getValue('name')).toBe 'test'
        expect(row.getValue('label')).toBe 'test'
        expect(row.getValue('type')).toBe 'text'
        expect(row.getValue('hint')).toBe 'test'
        expect(row.getValue('required')).toBe 'test'
        expect(row.getValue('relevant')).toBe 'test'

      it 'uses default attributes when type and label are passed in', () ->
        row = new $model.Row(type: 'text', label: 'passed label')
        row.initialize()

        expect(row.getValue('name')).toBe 'test'
        expect(row.getValue('label')).toBe 'passed label'
        expect(row.getValue('type')).toBe 'text'
        expect(row.getValue('hint')).toBe 'test'
        expect(row.getValue('required')).toBe 'test'
        expect(row.getValue('relevant')).toBe 'test'

      it 'uses passed attributes when more than type and label are passed in', () ->
        row = new $model.Row(type: 'text', label: 'passed label', name: 'passed name')
        row.initialize()

        expect(row.getValue('name')).toBe 'passed name'
        expect(row.getValue('label')).toBe 'passed label'
        expect(row.getValue('type')).toBe 'text'
        expect(row.getValue('hint')).toBeUndefined()
        expect(row.getValue('required')).toBeUndefined()
        expect(row.getValue('relevant')).toBeUndefined()
