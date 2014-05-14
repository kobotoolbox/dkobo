define [
        'cs!xlform/model.inputParser',
        'cs!xlform/model.choices',
        'cs!test/fixtures/surveys',
        ], (
            $inputParser,
            $choices,
            $surveys,
            )->

  describe '" $inputParser', ->
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
    describe '. loadChoiceLists()"', ->
      list = new $choices.ChoiceList()
      $inputParser.loadChoiceLists($surveys.pizza_survey.main().choices, list)

    describe '. parse()"', ->
      it 'parses group hierarchy', ->
        results = $inputParser.parseArr('survey', [
            {type: 'begin group', name: 'grp1'},
            {type: 'text', name: 'q1'},
            {type: 'end group'},
          ])
        expect(results).toEqual([
            {
              type: 'group',
              name: 'grp1',
              __rows: [{type: 'text', name: 'q1'}]
            }
          ])
      it 'parses nested groups hierarchy', ->
        results = $inputParser.parseArr('survey', [
            {type: 'begin group', name: 'grp1'},
            {type: 'begin group', name: 'grp2'},
            {type: 'text', name: 'q1'},
            {type: 'text', name: 'q2'},
            {type: 'end group'},
            {type: 'end group'},
          ])
        expect(results).toEqual([ { type : 'group', name : 'grp1', __rows : [ { type : 'group', name : 'grp2', __rows : [ { type : 'text', name : 'q1' }, { type : 'text', name : 'q2' } ] } ] } ])
      it 'parses non-grouped list of questions', ->
        results = $inputParser.parseArr('survey', [
            {type: 'text', name: 'q1'},
            {type: 'text', name: 'q2'},
          ])
        expect(results).toEqual([ { type : 'text', name : 'q1' }, { type : 'text', name : 'q2' } ])

    # describe '[.] sortByVisibility "', ->
    #   it 'method is defined', ->
    #     expect(false).toBe(true)
    #     expect($inputParser.sortByVisibility).toBeDefined()
    #   it 'throws an error if it receives the wrong input', ->
    #     objInp = ()-> $inputParser.sortByVisibility(@sampleSurveyObj)
    #     expect(objInp).toThrow()
    # 
    #   it 'receives the survey and separates visible fields', ->
    #     [visib, invisib] = $inputParser.sortByVisibility(@sampleSurveyObj.survey)

#   it 'parses a csv', ->
#     oneliner = "survey,,,\n,key1,key2,key3\n,val1,val2,val3\nchoices,,,\n,k4,k5\n,v4,v5"
#     $inputDeserializer(oneliner)
#     expect(deserialize(oneliner)).toEqual(@sampleSurveyObj)
#   it 'parses a json string', ->
#     oneline_json = """{"survey":[{"key1":"val1","key2":"val2","key3":"val3"}],"choices":[{"k4":"v4","k5":"v5"}]}"""
#     expect(deserialize(oneline_json)).toEqual(@sampleSurveyObj)
#   it 'parses a js object', ->
#     expect(deserialize(@sampleSurveyObj)).toEqual(@sampleSurveyObj)
# 
# describe '.validateParse notifies validity', ->
#   beforeEach ->
#     @validate = (obj, tf=true, expectedError=false)->
#       ctx = {}
#       isValid = $inputDeserializer.validateParse(obj, ctx)
#       expect(ctx).toBeDefined()
#       expect(isValid).toBe(tf)
#       expect(ctx.error).toEqual(expectedError)  if expectedError
# 
#   it 'valid with just survey sheet', ->
#     @validate survey: []
#   describe 'validateParse\'s invalid parameters are caught: ', ->
#     it '[string]', ->
#       @validate 'takes only object', false
#     it '[array]', ->
#       @validate ['needs to be an object'], false
# describe ' deserializes and records errors', ->
#   it ' when input is missing survey sheet', ->
#     ss2 = 
#       notSurvey: @sampleSurveyObj.survey
#       choices: @sampleSurveyObj.choices
#     context = {}
#     dump($inputDeserializer(ss2, context))
#     dump(context)
# 
# 
###
require ['cs!xlform/model.survey', 'cs!fixtures/surveys'], ($survey, $surveyFixtures)->
  Survey = $survey.Survey
  pizza_survey = $surveyFixtures.pizza_survey

  ensure_equivalent = (sFixId)->
    fixt = $surveyFixtures[sFixId]
    describe "fixtures/surveys.#{sFixId}:", ->
      it "the fixture exists", ->
        expect(fixt.csv).toBeDefined()
        expect(fixt.xlf).toBeDefined()
        expect(fixt.xlf2).toBeDefined()

      describe "the fixture imports from object", ->
        beforeEach ->
          @s1 = Survey.load(fixt.csv)
          @s2 = Survey.load(fixt.xlf)
          @s3 = Survey.load(fixt.xlf2)

        it "creates surveys", ->
          expect(@s1).toBeDefined()
          expect(@s2).toBeDefined()
          expect(@s3).toBeDefined()

        it "creates surveys with matching fingerprints", ->
          fingerprint = (s)->
            # something that ensures the output is equivalent
            "#{s.toCSV().length}"
          expect(fingerprint(@s1)).not.toBe('')
          expect(fingerprint(@s1)).toEqual(fingerprint(@s2))
          expect(fingerprint(@s1)).toEqual(fingerprint(@s3))
          expect(fingerprint(@s2)).toEqual(fingerprint(@s3))

  ensure_equivalent('pizza_survey')
###