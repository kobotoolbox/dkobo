define 'cs!xlform/mv.skipLogicHelpers', [
        'xlform/model.skipLogicParser',
        'cs!xlform/view.widgets'
        ], (
            $skipLogicParser,
            $viewWidgets
            )->

  skipLogicHelpers = {}

  class skipLogicHelpers.SkipLogicHelperFactory
    constructor: (@model_factory, @view_factory, @survey, @current_question, @serialized_criteria) ->
    create_presenter: (criterion_model, criterion_view, builder) ->
      return new skipLogicHelpers.SkipLogicPresenter criterion_model, criterion_view, builder
    create_builder: () ->
      return new skipLogicHelpers.SkipLogicBuilder @model_factory, @view_factory, @survey, @current_question, @
    create_context: () ->
      return new skipLogicHelpers.SkipLogicHelperContext @model_factory, @view_factory, @, @serialized_criteria

  class skipLogicHelpers.SkipLogicPresentationFacade
    constructor: (@model_factory, @helper_factory, @view_factory) ->
    serialize: () ->
      @context ?= @helper_factory.create_context()
      @context.serialize()
    render: (target) ->
      @context ?= @helper_factory.create_context()
      @context.render target

  class skipLogicHelpers.SkipLogicPresenter
    change_question: (question_name) ->
      @model.change_question question_name

      @question = @model._get_question()
      question_type = @question.get_type()
      @question.on 'remove', () =>
        @dispatcher.trigger 'remove:question', @

      @builder.operator_type = operator_type = @model.get('operator').get_type()

      @view.change_operator @builder.build_operator_view question_type
      @view.operator_picker_view.val @model.get('operator').get_value()
      @view.attach_operator()

      @builder.question_type = question_type

      @change_response_view question_type, @model.get('operator').get_type()

      @finish_changing()

    change_operator: (operator_id) ->
      @model.change_operator operator_id

      @change_response_view @model._get_question().get_type(), @model.get('operator').get_type()

      @finish_changing()

    change_response: (response_text) ->
      @model.change_response response_text
      @finish_changing()

    change_response_view: (question_type, operator_type) ->
      response_view = @builder.build_response_view @model._get_question(), question_type, operator_type
      response_view.model = @model.get 'response_value'

      @view.change_response response_view
      @view.attach_response()
      @view.response_value_view.val @model.get('response_value').get('value')

    finish_changing: () ->
      @determine_add_new_criterion_visibility()
      @builder.current_question.get('relevant').set 'value', @serialize_all()

    determine_add_new_criterion_visibility: () ->
      $add_new_criterion_button = @$add_new_criterion_button
      if !@model._get_question()
        $add_new_criterion_button.hide()
      else if @model.get('operator').get_type().id == 1
        $add_new_criterion_button.show()
      else if @model.get('response_value').get('value')  in ['', undefined] || @model.get('response_value').isValid() == false
        $add_new_criterion_button.hide()
      else
        $add_new_criterion_button.show()

    constructor: (@model, @view, @builder, @dispatcher) ->
      @view.presenter = @
      if @builder.survey
        @builder.survey.on 'choice-list-update', (row, key) =>
          if @destination
            @render(@destination)

        @builder.survey.on 'row-detail-change', (row, key) =>
          if @destination
            if key == 'label'
              @render(@destination)
      else
        console.error "this.builder.survey is not yet available"


    render: (@destination) ->
      @view.question_picker_view = @builder.build_question_view()
      @view.render()
      @view.question_picker_view.val @model.get('question_cid')
      @view.operator_picker_view.val @model.get('operator').get_value()
      @view.response_value_view.val @model.get('response_value')?.get('value')
      @view.attach_to(destination)



      @determine_add_new_criterion_visibility()

    serialize: () ->
      @model.serialize()

  class skipLogicHelpers.SkipLogicHelperContext
    render: (@destination) ->
      if @destination?
        @destination.empty()
        @state.render destination
      return
    serialize: () ->
      return @state.serialize()
    use_criterion_builder_helper: () ->
      @builder ?= @helper_factory.create_builder()
      presenters = @builder.build_criterion_builder(@state.serialize())

      if presenters == false
        @state = null
      else
        @state = new skipLogicHelpers.SkipLogicCriterionBuilderHelper(presenters[0], presenters[1], @builder, @view_factory, @)
        @render @destination
      return
    use_hand_code_helper: () ->
      @state = new skipLogicHelpers.SkipLogicHandCodeHelper(@state.serialize(), @builder, @view_factory, @)
      @render @destination
      return
    use_mode_selector_helper : () ->
      @state = new skipLogicHelpers.SkipLogicModeSelectorHelper(@view_factory, @)
      @render @destination
      return
    constructor: (@model_factory, @view_factory, @helper_factory, serialized_criteria) ->
      @state = serialize: () -> return serialized_criteria
      if !serialized_criteria? || serialized_criteria == ''
        serialized_criteria = ''
        @use_mode_selector_helper()
      else
        @use_criterion_builder_helper()

      if !@state?
        @state = serialize: () -> return serialized_criteria
        @use_hand_code_helper()

  class skipLogicHelpers.SkipLogicCriterionBuilderHelper
    determine_criterion_delimiter_visibility: () ->
      if @presenters.length < 2
        @$criterion_delimiter.hide()
      else
        @$criterion_delimiter.show()
    render: (destination) ->
      @view.render().attach_to destination
      @$criterion_delimiter = @view.$(".skiplogic__delimselect")
      @$add_new_criterion_button = @view.$('.skiplogic__addcriterion')

      @determine_criterion_delimiter_visibility()

      @destination = @view.$('.skiplogic__criterialist')
      dispatcher = _.clone Backbone.Events
      dispatcher.on 'remove:question', (presenter) =>
        @remove presenter.model.cid
        
      _.each @presenters, (presenter) =>
        presenter.dispatcher = dispatcher
        presenter.$add_new_criterion_button = @$add_new_criterion_button
        presenter.serialize_all = _.bind @serialize, @
        presenter.render @destination

    serialize: () ->
      serialized = _.map @presenters, (presenter) ->
        presenter.serialize()
      _.filter(serialized, (crit) -> crit).join(' ' + @view.criterion_delimiter + ' ')
    add_empty: () ->
      presenter = @builder.build_empty_criterion_logic()
      presenter.$add_new_criterion_button = @$add_new_criterion_button
      presenter.serialize_all = _.bind @serialize, @
      presenter.render @destination
      @presenters.push presenter
      @determine_criterion_delimiter_visibility()
    remove: (id) ->
      _.each @presenters, (presenter, index) =>
        if presenter? && presenter.model.cid == id
          presenter = @presenters.splice(index, 1)
          presenter[0].view.$el.remove()

      if @presenters.length == 0
        @context.use_mode_selector_helper()
    constructor: (@presenters, separator, @builder, @view_factory, @context) ->
      @view = @view_factory.create_criterion_builder_view()
      @view.criterion_delimiter = (separator || 'and').toLowerCase()
      @view.facade = @

      @builder.survey.on 'sortablestop', () =>
        questions = builder.questions()
        _.each @presenters, (presenter) =>
          if !(presenter.model._get_question() in questions)
            @remove presenter.model.cid

    switch_editing_mode: () ->
      @builder.build_hand_code_criteria @serialize()

  class skipLogicHelpers.SkipLogicHandCodeHelper
    render: ($destination) ->
      $destination.append @$parent
      @textarea.render().attach_to @$parent
      @button.render().attach_to @$parent
      @button.bind_event 'click', () => @context.use_mode_selector_helper()
    serialize: () ->
      @textarea.$el.val() || @criteria
    constructor: (@criteria, @builder, @view_factory, @context) ->
      @$parent = $('<div>')
      @textarea = @view_factory.create_textarea @criteria, 'skiplogic__handcode-edit'
      @button = @view_factory.create_button 'x', 'skiplogic-handcode__cancel'

  class skipLogicHelpers.SkipLogicModeSelectorHelper
    render: ($destination) ->
      $parent = $('<div>')
      $destination.append $parent
      @criterion_builder_button.render().attach_to $parent
      @handcode_button.render().attach_to $parent

      @criterion_builder_button.bind_event 'click', () => @context.use_criterion_builder_helper()
      @handcode_button.bind_event 'click', () => @context.use_hand_code_helper()

    serialize: () ->
      return ''
    constructor: (view_factory, @context) ->
      @criterion_builder_button = view_factory.create_button '<i class="fa fa-plus"></i> Add a condition', 'skiplogic__button skiplogic__select-builder'
      @handcode_button = view_factory.create_button '<i>${}</i> Manually enter your skip logic in XLSForm code', 'skiplogic__button skiplogic__select-handcode'
      ###@view = @view_factory.create_skip_logic_picker_view(context)###
    switch_editing_mode: () -> return

  class skipLogicHelpers.SkipLogicBuilder
    # build_hand_code_criteria: (criteria) ->
    #   new XLF.SkipLogicHandCodeFacade criteria, @, @view_factory
    parse_skip_logic_criteria: (criteria) ->
      return $skipLogicParser criteria

    build_criterion_builder: (serialized_criteria) ->
      if serialized_criteria == ''
        return [[@build_empty_criterion_logic()], 'and']

      try
        parsed = @parse_skip_logic_criteria serialized_criteria
        criteria = _.filter(_.map(parsed.criteria, @build_criterion_logic), (item) -> !!item)
        if criteria.length == 0
          criteria.push @build_empty_criterion_logic()

        return [criteria, parsed.operator]

      catch e
        return false

    build_operator_logic: (question_type, operator_type, criterion) =>
      return [
        @build_operator_model(question_type, operator_type, operator_type.symbol[criterion.operator]),
        @build_operator_view(question_type)
      ]

    build_operator_model: (question_type, operator_type, symbol) ->
      return @model_factory.create_operator(
        (if operator_type.type == 'existence' then 'existence' else question_type.equality_operator_type),
        symbol,
        operator_type.id)

    build_operator_view: (question_type) ->
      operators = _.filter(skipLogicHelpers.operator_types, (op_type) -> op_type.id in question_type.operators)
      @view_factory.create_operator_picker operators

    build_question_view: () ->
      model = new $viewWidgets.DropDownModel()
      set_options = () =>
        options = _.map @questions(), (row) ->
          value: row.cid
          text: row.getValue("label")

        options.unshift value: -1, text: 'Select question from list'
        model.set 'options', options

      set_options()
      @survey.on 'sortablestop', set_options

      @view_factory.create_question_picker model

    build_response_view: (question, question_type, operator_type) ->
      responses = null

      if question_type.response_type == 'dropdown'
        responses = question.getList().options

      response_type = if operator_type.response_type? then operator_type.response_type else question_type.response_type

      @view_factory.create_response_value_view(response_type, responses)

    build_criterion_logic: (criterion) =>
      @operator_type = _.find skipLogicHelpers.operator_types, (op_type) ->
          criterion.operator in op_type.parser_name

      question = @_get_question criterion
      if !question
        return false

      question_type = question.get_type()

      [operator_model, operator_picker_view] = @build_operator_logic question_type, @operator_type, criterion

      criterion_model = @model_factory.create_criterion_model()
      criterion_model.set('operator', operator_model)
      criterion_model.change_question question.cid

      question_picker_view = @build_question_view()

      response_value_model = @model_factory.create_response_model question_type.response_type
      criterion_model.set('response_value', response_value_model)
      response_value_model.set('value', criterion.response_value)

      response_value_view = @build_response_view question, question_type, @operator_type
      response_value_view.model = response_value_model

      criterion_view = @view_factory.create_criterion_view question_picker_view, operator_picker_view, response_value_view
      criterion_view.model = criterion_model

      new skipLogicHelpers.SkipLogicPresenter(criterion_model, criterion_view, @)

    _get_question: (criterion) ->
      @survey.findRowByName criterion.name

    build_empty_criterion_logic: () =>
      criterion_model = @model_factory.create_criterion_model()
      criterion_model.set('operator', @model_factory.create_operator('empty'))

      question_picker_view = @build_question_view()


      criterion_view = @view_factory.create_criterion_view(
        question_picker_view,
        @view_factory.create_operator_picker([]),
        @view_factory.create_response_value_view('empty')
      )

      criterion_view.model = criterion_model

      @helper_factory.create_presenter criterion_model, criterion_view, @

    questions: () ->
      questions = []
      limit = false

      non_selectable = ['datetime', 'time', 'note', 'calculate', 'group']

      @survey.forEachRow (question) =>
        limit = limit || question is @current_question
        if !limit && question.getValue('type') not in non_selectable
          questions.push question
      , includeGroups:true
      questions

    constructor: (@model_factory, @view_factory, @survey, @current_question, @helper_factory) -> return


  skipLogicHelpers.question_types =
    default:
      operators: [1, 2]
      equality_operator_type: 'text'
      response_type: 'text'
      name: 'default'
    select_one:
      operators: [2, 1]
      equality_operator_type: 'text'
      response_type: 'dropdown'
      name: 'select_one'
    select_multiple:
      operators: [2, 1]
      equality_operator_type: 'select_multiple'
      response_type: 'dropdown'
      name: 'select_multiple'
    integer:
      operators: [3, 1, 2, 4]
      equality_operator_type: 'basic'
      response_type: 'integer'
      name: 'integer'
    barcode:
      operators: [3, 1, 2, 4]
      equality_operator_type: 'text'
      response_type: 'text'
      name: 'barcode'
    decimal:
      operators: [1, 2, 3, 4]
      equality_operator_type: 'basic'
      response_type: 'decimal'
      name: 'decimal'
    geopoint:
      operators: [1]
      name: 'geopoint'
    image:
      operators: [1]
      name: 'image'
    audio:
      operators: [1]
      name: 'audio'
    video:
      operators: [1]
      name: 'video'
    acknowledge:
      operators: [1]
      name: 'acknowledge'
    date:
      operators: [2, 3, 4]
      equality_operator_type: 'text'
      response_type: 'text'
      name: 'date'

  skipLogicHelpers.operator_types = [
    {
      id: 1
      type: 'existence'
      label: 'Was Answered'
      negated_label: 'Was not Answered'
      abbreviated_label: 'Was Answered'
      abbreviated_negated_label: 'Was not Answered'
      parser_name: ['ans_notnull','ans_null']
      symbol: {
        ans_notnull: '!=',
        ans_null: '='
      }
      response_type: 'empty'
    }
    {
      id: 2
      type: 'equality'
      label: ''
      negated_label: 'not'
      abbreviated_label: '='
      abbreviated_negated_label: '!='
      parser_name: ['resp_equals', 'resp_notequals', 'multiplechoice_selected', 'multiplechoice_notselected']
      symbol: {
        resp_equals: '=',
        resp_notequals: '!=',
        multiplechoice_selected: '='
        multiplechoice_notselected: '!='
      }
    }
    {
      id: 3
      type: 'equality'
      label: 'Greater Than'
      negated_label: 'Less Than'
      abbreviated_label: '>'
      abbreviated_negated_label: '<'
      parser_name: ['resp_greater', 'resp_less']
      symbol: {
        resp_greater: '>'
        resp_less: '<'
      }
    }
    {
      id: 4
      type: 'equality'
      label: 'Greater Than or Equal to'
      negated_label: 'Less Than or Equal to'
      abbreviated_label: '>='
      abbreviated_negated_label: '<='
      parser_name: ['resp_greaterequals', 'resp_lessequals']
      symbol: {
        resp_greaterequals: '>=',
        resp_lessequals: '<='
      }
    }
  ]

  skipLogicHelpers
