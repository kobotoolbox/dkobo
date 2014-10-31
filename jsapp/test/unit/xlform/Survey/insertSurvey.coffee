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

      row = new $model.Row()

      second_survey = $model.Survey.create()
      second_survey.addRow(row)

      survey.insertSurvey second_survey

      expect(survey.rows.length).toBe 1
      expect(survey.rows.at(0).toJSON()).toEqual row.toJSON()

    it 'inserts each row within the passed survey starting from the provided index', () ->
      create_simple_row = (name)-> new $model.Row(type: 'text', name: name)

      survey1 = $model.Survey.create()
      for row_name in ['a', 'b', 'c']
        survey1.addRow(create_simple_row(row_name))

      append_survey_with_name_to_index = (name, index)->
        tmp_survey = $model.Survey.create()
        tmp_survey.addRow(create_simple_row(name))
        survey1.insertSurvey tmp_survey, index

      append_survey_with_name_to_index('z', 3)
      append_survey_with_name_to_index('y', 2)
      append_survey_with_name_to_index('x', 1)

      survey1_names = survey1.rows.map (r)-> r.getValue('name')

      # a b c
      #  x y z
      expect(survey1_names).toEqual(['a', 'x', 'b', 'y', 'c', 'z'])

    it 'carries over choice list from one survey to the next', ->
      # a pre-built survey with a choice list
      survey1 = $model.Survey.load("""
        survey,,,
        ,type,name,label
        ,select_one x,s1,"select one"
        choices,,,
        ,"list name",name,label
        ,x,letters,"A B C"
        ,x,numbers,"1 2 3"
        """)

      # an empty survey
      survey2 = $model.Survey.create()

      list_json_options = [
        {
          name: 'letters'
          label: 'A B C'
        }, {
          name: 'numbers'
          label: '1 2 3'
        }
      ]
      expect(survey1.rows.at(0).getList().toJSON().options).toEqual(list_json_options)
      survey2.insertSurvey(survey1)

      expect(survey2.rows.at(0).getList().toJSON().options).toEqual(list_json_options)

      survey3 = $model.Survey.load(survey2.toCSV())
      expect(survey3.rows.at(0).getList().toJSON().options).toEqual(list_json_options)

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
