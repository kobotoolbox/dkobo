define 'cs!test/unit/xlform/Row/getters', [
          'cs!xlform/_model',
          'cs!xlform/model.configs',
          ], (
              $model,
              $configs,
              )->

  describe 'Getters', () ->
    describe 'Label getter', () ->
      it 'returns label when present', () ->
        row = new $model.Row(type: 'text', label: 'passed label')

        expect(row.getLabel()).toBe('passed label')
      it 'returns first label with language suffix when no label present', () ->
        row = new $model.Row(type: 'text', 'label::spanish': 'etiqueta pasada')

        expect(row.getLabel()).toBe('etiqueta pasada')