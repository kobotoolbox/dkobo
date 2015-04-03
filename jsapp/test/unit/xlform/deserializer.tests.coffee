define [
        'cs!xlform/model.inputDeserializer',
        'cs!test/fixtures/surveys',
        ], (
            $inputDeserializer,
            $surveys,
            )->

  deserialize = $inputDeserializer.deserialize
  describe '$inputDeserializer', ->
    beforeEach ->
      @sampleSurveyObj =
        survey: [
          key1: "val1"
          key2: "val2"
          key3: "val3"
        ]
        choices: [
          k4: "v4"
          k5: "v5"
        ]

    describe '. deserialize parses csv, json, and object', ->
      it 'has deserialize method defined', ->
        expect($inputDeserializer.deserialize).toBeDefined()
      it 'parses a csv', ->
        oneliner = "survey,,,\n,key1,key2,key3\n,val1,val2,val3\nchoices,,,\n,k4,k5\n,v4,v5"
        $inputDeserializer(oneliner)
        expect(deserialize(oneliner)).toEqual(@sampleSurveyObj)
      it 'parses a json string', ->
        oneline_json = """{"survey":[{"key1":"val1","key2":"val2","key3":"val3"}],"choices":[{"k4":"v4","k5":"v5"}]}"""
        expect(deserialize(oneline_json)).toEqual(@sampleSurveyObj)
      it 'parses a js object', ->
        expect(deserialize(@sampleSurveyObj)).toEqual(@sampleSurveyObj)

    describe '.validateParse notifies validity', ->
      beforeEach ->
        @validate = (obj, tf=true, expectedError=false)->
          ctx = {}
          isValid = $inputDeserializer.validateParse(obj, ctx)
          expect(ctx).toBeDefined()
          expect(isValid).toBe(tf)
          expect(ctx.error).toEqual(expectedError)  if expectedError

      it 'with just survey sheet', ->
        @validate survey: []
      describe 'but does not accept non-object parameters', ->
        it '[string]', ->
          @validate 'cant be a string', false
        it '[array]', ->
          @validate ['cant be an array'], false
    describe 'deserializes and records errors', ->
      it 'when input is missing survey sheet', ->
        ss2 =
          notSurvey: @sampleSurveyObj.survey
          choices: @sampleSurveyObj.choices
        context = {validate: true}
        $inputDeserializer(ss2, context)
        expect(context.error).toBeDefined()
        expect(context.error).toContain('survey sheet')
