define 'cs!test/unit/xlform/Survey/insertSurvey', [
          'cs!xlform/_model',
          'cs!xlform/model.choices'
          ], (
              $model,
              $choices
              )->

  describe 'Insert Survey', () ->
    it 'inserts each row within the passed survey at the end of the target survey', () ->
      survey = $model.Survey.create()

      survey.insert_row = (row) ->
        @rows.add row

      row = new $model.Row()
      survey.insertSurvey rows: models: [row]

      expect(survey.rows.length).toBe 1
      expect(survey.rows.at(0)).toBe row

    it 'inserts each row within the passed survey starting from the provided index', () ->
      survey = $model.Survey.create()
      survey.insert_row = (row, at) -> @rows.add row, at: at

      new_row = new $model.Row()
      survey.rows.add new $model.Row()
      survey.rows.add new $model.Row()
      survey.rows.add new $model.Row()

      survey.insertSurvey rows: models: [new_row], 2
      expect(survey.rows.length).toBe 4
      expect(survey.rows.models[2]).toBe new_row

  describe 'Insert Row', () ->
    it 'adds the passed row to the row collection of the target survey', () ->
      survey = $model.Survey.create()

      survey.rows.original_add = survey.rows.add

      new_row = new $model.Row()

      survey.insert_row(new_row, 0)

      expect(survey.rows.length).toBe 1
      expect(survey.rows.models[0].toJSON()).toEqual new_row.toJSON()

    it 'adds the passed row`s choices if its type is single or multi select', () ->
      survey = $model.Survey.create()

      new_row = new $model.Row(type: 'select_multiple')

      choices = new $choices.ChoiceList()
      new_row.getList = () -> return choices

      survey.insert_row(new_row, 0)

      row = survey.rows.models[0].toJSON()
      row.type = row.type.split(' ')[0]

      expect(survey.rows.length).toBe 1
      expect(row).toEqual new_row.toJSON()

      expect(survey.choices.models[0].options.toJSON()).toEqual choices.options.toJSON()

    it 'deduplicates the passed row`s name', () ->
      survey = $model.Survey.create()

      survey.rows.original_add = survey.rows.add

      new_row = new $model.Row()
      new_row.attributes.name.attributes.value = 'new_question'

      survey.insert_row(new_row, 0)
      survey.insert_row(new_row, 0)

      expect(survey.rows.length).toBe 2
      expect(survey.rows.models[0].attributes.name.attributes.value).toBe 'new_question_001'
