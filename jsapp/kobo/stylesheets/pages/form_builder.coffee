###
Associated with "form_builder.scss"

BEM:
block:
  "formb" #formbuilder
elems:
  "surveybuttons" # 
###

@sandbox = (el)->
  $wrap = $ $.parseHTML contents()
  # $header = $wrap.find(".survey-header").eq(0)
  # $list = $wrap.find("ul").eq(0)
  $(el).html $wrap
  ``

contents = ->
  ###
  the form builder is contained within a <section>
  ###
  
  # TODO: merge .-form-builder (wrap) with .form-builder (margin)
  """
  <section class="-form-builder form-builder">
    <div class="formb__surveybuttons"></div>
    <div class="survey-header">
      SurveyHeader
    </div>
    <div class="survey-editor">
      <ul>
        #{empty_survey_message()}
        #{li_row('text')}
        #{li_row('longtext')}
        #{li_row('number')}
        #{li_row('indrag')}
        #{li_row('dragplaceholder')}
      </ul>
    </div>
  </section>
  """


CENSUS_TEXTS =
  integer: "How many people were living or staying in this house, apartment, or mobile home on April 1, 2010?",
  select1yn: "Were there any additional people staying here April 1, 2010 that you did not include in Question 1?",
  select1: "Is this house, apartment, or mobile home: owned with mortgage, owned without mortgage, rented, occupied without rent?",
  text:    "What is your telephone number?",

###
  ["integer","q1","How many people were living or staying in this house, apartment, or mobile home on April 1, 2010?"
  ,"select_one yes_no","q2","Were there any additional people staying here April 1, 2010 that you did not include in Question 1?"
  ,"select_one ownership_type or_other","q3","Is this house, apartment, or mobile home: owned with mortgage, owned without mortgage, rented, occupied without rent?"
  ,"text","q4","What is your telephone number?"
  ,"text","q5","Please provide information for each person living here. Start with a person here who owns or rents this house, apartment, or mobile home. If the owner or renter lives somewhere else, start with any adult living here. This will be Person 1. What is Person 1's name?"
  ,"select_one male_female","q6","What is Person 1's sex?"
  ,"date","q7","What is Person 1's age and Date of Birth?"

###
loremipsum = """
  Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.
"""

li_row = (variation='text') ->
  note = """
    card preview <strong><code>:#{variation}</code></strong>
  """

  if variation is 'dragplaceholder'
    drag_placeholder_row(note: note)
  else
    standard_row(variation, note: note)

drag_placeholder_row = ({note})->
  """
  <li class="xlf-row-view">
    #{sidenote(note, 'absrt')}
    <div class="card card--placeholder">
        <span>Drag and drop to reorder</span>
    </div>
  </li>
  """

standard_row = (variation='text', {note}) ->

  _text = if variation in ['text', 'indrag']
    CENSUS_TEXTS.text
  else if variation is 'longtext'
    loremipsum
  else if variation is 'number'
    CENSUS_TEXTS.integer
  else
    "<i>no text for <code>:#{variation}</code></i>"

  card__indicator = """
    <div class="card__indicator">
      <div class="noop card__indicator__icon"><i class="fa fa-list"></i></div>
    </div>
  """
  card__butons = """
    <div class="card__buttons">
      <a href="#" class="card__buttons__button gray"><i class="fa fa-cog"></i></a>
      <a href="#" class="card__buttons__button red"><i class="fa fa-trash-o"></i></a>
      <a href="#" class="card__buttons__button"><i class="fa fa-copy"></i></a>
    </div>
  """

  """
  <li class="xlf-row-view">
    #{sidenote(note, 'absrt')}

    <div class="card">
      #{card__indicator}
      <div class="card__text">
        #{_text}
      </div>
      #{card__butons}
    </div>
  </li>
  """

empty_survey_message = ->
  ###
  The empty survey message is an empty <li>
  ###
  note = """
  When the survey is empty, this is the only item shown.
  """

  """
  <li class="survey-editor__null-top-row">
    #{sidenote(note, 'absrt')}

    <p class="survey-editor__message well">
      <b>This form is currently empty.</b>
      <br>
      You can add questions, notes, prompts, or other fields by clicking on the "+" sign below.
    </p>
  </li>
  """

sidenote = (msg, styling_variation='inline-block')->
  """
  <div class="sidenote-wrap-#{styling_variation}">
    <div class="sidenote">
      #{msg}
    </div>
  </div>
  """
