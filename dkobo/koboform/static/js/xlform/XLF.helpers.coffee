class XLF.SkipLogicBuilder
  build: () ->
    dispatcher = _.clone Backbone.Events
    skip_logic_model = @modelFactory

    dispatcher.on 'change:question', (value) ->
      skip_logic_model.set_question value

  constructor: (@modelFactory, @viewFactory, @survey, currentQuestion) ->
    @questions = []
    break = false

    @survey.forEachRow (question) =>
      break = break || question is currentQuestion
      if !break
        @questions.push question
