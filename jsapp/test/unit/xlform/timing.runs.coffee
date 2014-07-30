# test end-to-end of the system
MAX_TIME = 10000
NUM_ROWS = 150

define [
        'cs!xlform/_view',
        'cs!xlform/_model',
        ], (
            $view,
            $model,
            )->

  csv_survey_500_with_skiplogic = ->
    # returns a simple csv survey
    lines = ["survey,,,",
             ",type,label,relevant,name",]
    relevant = ""
    for n in [1..NUM_ROWS]
      if n > 1
        qref = """${q#{n-1}}"""
        relevant = "#{qref} != ''"
      lines.push """,text,"Question #{n}",#{relevant},q#{n}"""
    lines.join('\n')

  csv_survey_500_noskiplogic = ->
    lines = ["survey,,,",
             ",type,label,name",]
    for n in [1..NUM_ROWS]
      lines.push """,text,"Question #{n}",q#{n}"""
    lines.join('\n')

  append_survey_app = (survey)->
    app = new $view.SurveyApp(survey: survey)
    $('#wrap').html(app.el)
    app.render()
    app

  describe 'a number of scenarios to test memory usage', ->
    # describe 'timing model', ->
    #   time "MODEL_ONLY survey with #{NUM_ROWS} questions (no skip logic)", ->
    #     survey = $model.Survey.load(csv_survey_500_noskiplogic())

    #   time "MODEL_ONLY with #{NUM_ROWS} questions + SKIP LOGIC", ->
    #     survey = $model.Survey.load(csv_survey_500_with_skiplogic())

    describe 'timing view', ->

      # time "FULL_VIEW survey with #{NUM_ROWS} questions (no skip logic)", ->
      #   survey = $model.Survey.load(csv_survey_500_noskiplogic())
      #   append_survey_app(survey)

      time "FULL_VIEW survey with #{NUM_ROWS} questions + SKIP LOGIC", ->
        survey = $model.Survey.load(csv_survey_500_with_skiplogic())
        append_survey_app(survey)

      # time "FULL_VIEW survey with #{NUM_ROWS} questions (no skip logic) + BUILD_CSV", ->
      #   survey = $model.Survey.load(csv_survey_500_noskiplogic())
      #   app = append_survey_app(survey)
      #   built_csv = app.survey.toCSV()
      #   $('#wrap').empty()

      time "FULL_VIEW survey with #{NUM_ROWS} questions + SKIP LOGIC + BUILD_CSV", ->
        survey = $model.Survey.load(csv_survey_500_with_skiplogic())
        app = append_survey_app(survey)
        built_csv = app.survey.toCSV()

  beforeEach ->
    @wrap = $('<div>', id: 'wrap').prependTo('body')

  afterEach ->
    @wrap.remove()

time = do ->
  $el = false
  activate = ->
    $el = $("<div>", class: 'timelog').prependTo('body')
  timeLog = (str, success, diff)->
    activate()  unless $el

    successMsg = if success then 'success' else 'fail'
    tlClass = "timelog-item timelog-item--#{successMsg}"
    $("<p>", class: tlClass, text: "time #{successMsg}: #{str} [#{diff}]").appendTo($el)
  fn = (str, limit, fn)->

    if "function" is typeof limit
      fn = limit
      limit = MAX_TIME
    it str, ()->
      if performance?
        totalJSHeapSize0 = performance.memory.totalJSHeapSize
        usedJSHeapSize0 = performance.memory.usedJSHeapSize

      before = new Date().getTime()
      fn.apply(@, arguments)
      diff = new Date().getTime() - before
      timeLog str, diff < limit, diff
      if diff > limit
        expect(diff).toBeLessThan(limit)

      if performance?
        totalJSHeapSize1 = performance.memory.totalJSHeapSize
        usedJSHeapSize1 = performance.memory.usedJSHeapSize
        log "totalJSHeapSize", totalJSHeapSize1 - totalJSHeapSize0, [totalJSHeapSize0, totalJSHeapSize1]
        log "usedJSHeapSize", usedJSHeapSize1 - usedJSHeapSize0, [usedJSHeapSize0, usedJSHeapSize1]

  fn

$ ->
  # requires the --enable-memory-info flag on chrome boot
  if window.performance?
    log "totalJSHeapSize", performance.memory.totalJSHeapSize
    log "usedJSHeapSize", performance.memory.usedJSHeapSize

  css_styles = """
  .timelog {
    z-index: 999;
    position: fixed;
    background: rgba(255,255,255,0.95);
    width: 100%;
    bottom: 0px;
    padding: 0px 20px
  }
  .timelog-item {
    border: 1px solid #bbb;
    color: red;
    padding: 5px 12px;
    margin-bottom: 12px;
  }
  .timelog-item--fail {
    border-color: red;
    background-color: rgba(255,0,0,0.2);
    color: red;
  }
  .timelog-item--success {
    border-color: green;
    color: green;
  }
  """
  $('<style>', type: 'text/css', html: css_styles).appendTo('head')

if window.performance
  performance.onwebkitresourcetimingbufferfull = ->
    log "onwebkitresourcetimingbufferfull"

