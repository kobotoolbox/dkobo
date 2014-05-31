describe "xlform survey model (XLF.Survey)", ->
  beforeEach ->
    @pizzaSurvey = XLF.createSurveyFromCsv(PIZZA_SURVEY)
    @createSurveyCsv = (survey=[],choices=[])->
      choiceSheet = if choices.length is 0 then "" else """
      choices,,,
      ,list name,name,label
      ,#{choices.join("\n,")}
      """
      """
      survey,,,
      ,type,name,label,hint
      ,#{survey.join("\n,")}
      #{choiceSheet}
      """
    @createSurvey = (survey=[],choices=[])=>
      XLF.createSurveyFromCsv @createSurveyCsv survey, choices
    @firstRow = (s)-> s.rows.at(0)
    @compareCsvs = (x1, x2)->
      x1r = x1.split("\n")
      x2r = x2.split("\n")
      for r in _.min([x1r.length, x2r.length])
        expect(x1r[r]).toBe(x2r[r])
      expect(x1).toBe(x2)
    @dumpAndLoad = (scsv)=>
      s1 = XLF.createSurveyFromCsv scsv
      x1 = s1.toCSV()
      s2 = XLF.createSurveyFromCsv x1
      x2 = s2.toCSV()
      @compareCsvs(x1, x2)

  it "creates xlform", ->
    xlf = new XLF.Survey name: "Sample"
    expect(xlf).toBeDefined()
    expect(xlf instanceof XLF.Survey).toBe(true)
    expect(xlf.get("name")).toBe("Sample")

  it "ensures every node has access to the parent survey", ->
    @pizzaSurvey.getSurvey

  it "can append a survey to another", ->
    dead_simple = @createSurvey(['text,q1,Question1,q1hint', 'text,q2,Question2,q2hint'])
    expect(dead_simple.rows.length).toBe(2)
    expect(@pizzaSurvey.rows.length).toBe(1)
    dead_simple.insertSurvey(@pizzaSurvey)

    expect(dead_simple.rows.length).toBe(3)
    expect(dead_simple.rows.at(2).getValue("name")).toBe("likes_pizza")

  it "can import from csv_repr", ->
    expect(@pizzaSurvey.rows.length).toBe(1)
    firstRow = @pizzaSurvey.rows.at(0)
    expect(firstRow.getValue("name")).toEqual("likes_pizza")

  describe "with simple survey", ->
    beforeEach ->
      @firstRow = @pizzaSurvey.rows.at(0)
    describe "lists", ->
      it "iterates over every row", ->
        expect(@pizzaSurvey.rows).toBeDefined()
        expect(@firstRow).toBeDefined()
      it "can add a list as an object", ->
        expect(@pizzaSurvey.choices.length).toBe(1)
        @pizzaSurvey.choices.add LISTS.gender
        expect(@pizzaSurvey.choices.length).toBe(2)
        x1 = @pizzaSurvey.toCsvJson()

        # it should prevent duplicate lists with the same id
        @pizzaSurvey.choices.add LISTS.yes_no
        expect(@pizzaSurvey.choices.length).toBe(2)
        x2 = @pizzaSurvey.toCsvJson()
        expect(x1).toEqual(x2)
      it "can add row to a specific index", ->
        expect(@pizzaSurvey.addRowAtIndex).toBeDefined()
        # last question
        rowc = @pizzaSurvey.rows.length
        expect(@pizzaSurvey.rows.length).toBe 1
        @pizzaSurvey.addRowAtIndex({
          name: "lastrow",
          label: "last row",
          type: "text"
          }, rowc)
        expect(@pizzaSurvey.rows.length).toBe 2
        expect(@pizzaSurvey.rows.last().get("label").get("value")).toBe("last row")

        @pizzaSurvey.addRowAtIndex({
          name: "firstrow",
          label: "first row",
          type: "note"
          }, 0)

        expect(@pizzaSurvey.rows.length).toBe 3
        expect(@pizzaSurvey.rows.first().get("label").get("value")).toBe("first row")

        @pizzaSurvey.addRowAtIndex({
          name: "secondrow",
          label: "second row",
          type: "note"
          }, 1)

        expect(@pizzaSurvey.rows.length).toBe 4
        expect(@pizzaSurvey.rows.at(1).get("label").get("value")).toBe("second row")

        labels = _.map @pizzaSurvey.rows.pluck("label"), (i)-> i.get("value")
        expect(labels).toEqual([ 'first row', 'second row', 'Do you like pizza?', 'last row' ])

    it "row types changing is trackable", ->
      expect(@firstRow.getValue("type")).toBe("select_one yes_no")
      typeDetail = @firstRow.get("type")
      expect(typeDetail.get("typeId")).toBe("select_one")
      expect(typeDetail.get("list").get("name")).toBe "yes_no"

      list = @firstRow.getList()
      expect(list).toBeDefined()
      expect(list.get("name")).toBe("yes_no")

  describe "with custom surveys", ->
    beforeEach ->
      @createSurveyCsv = (survey=[],choices=[])->
        choiceSheet = if choices.length is 0 then "" else """
        choices,,,
        ,list name,name,label
        ,#{choices.join("\n,")}
        """
        """
        survey,,,
        ,type,name,label,hint
        ,#{survey.join("\n,")}
        #{choiceSheet}
        """
      @createSurvey = (survey=[],choices=[])=>
        XLF.createSurveyFromCsv @createSurveyCsv survey, choices
      @firstRow = (s)-> s.rows.at(0)
      @compareCsvs = (x1, x2)->
        x1r = x1.split("\n")
        x2r = x2.split("\n")
        for r in _.min([x1r.length, x2r.length])
          expect(x1r[r]).toBe(x2r[r])
        expect(x1).toBe(x2)

      @dumpAndLoad = (scsv)=>
        s1 = XLF.createSurveyFromCsv scsv
        x1 = s1.toCSV()
        s2 = XLF.createSurveyFromCsv x1
        x2 = s2.toCSV()
        @compareCsvs(x1, x2)

    it "breaks with an unk qtype", ->
      # makeInvalidTypeSurvey = =>
      #   @createSurvey ["telegram,a,a,a"]
      # expect(makeInvalidTypeSurvey).toThrow()

    it "exports and imports without breaking", ->
      scsv = @createSurveyCsv ["text,text,text,text"]
      @dumpAndLoad scsv
      # types = ["note", "text", "integer", "decimal",
      #         "geopoint", "image", "barcode", "date",
      #         "datetime", "audio", "video", "select_one",
      #         "select_multiple"]

    it "tries a few question types", ->
      srv = @createSurvey ["text,text,text,text"]
      row1 = srv.rows.at(0)

      r1type = row1.get("type")
      expect(r1type.get("rowType").name).toBe("text")

      # # a survey with 2 lists: "x" and "y"
      srv = @createSurvey [""""select_multiple x",a,a,a"""],
                          ["x,ax,ax","x,bx,bx,","y,ay,ay","y,by,by"]

      row1 = srv.rows.at(0)
      r1type = row1.get("type")
      expect(r1type.get("typeId")).toBe("select_multiple")
      expect(r1type.get("list").get("name")).toBe("x")
      expect(row1.getList().get("name")).toBe("x")
      # change row to to "select_multiple y".

      r1type.set("value", "select_multiple y")
      expect(r1type.get("typeId")).toBe("select_multiple")
      expect(r1type.get("list").get("name")).toBe("y")
      expect(row1.toJSON().type).toBe("select_multiple y")
      expect(row1.getList().get("name")).toBe("y")

      # change row to "text"
      row1.get("type").set("value", "text")
      expect(row1.get("type").get("value")).toBe("text")

      # Right now, thinking that we should keep the list around
      # and test to make sure the exported value doesn't have a list
      expect(row1.get("type").get("list").get("name")).toBeDefined()
      expect(row1.getList().get("name")).toBeDefined()
      expect(row1.toJSON().type).toBe("text")

      # # adding an invalid list will break things.
      #
      # I'm thinking: adding an invalid list will only break validation of
      # the survey. If it's not defined, it will prompt the user to make
      # the row valid.
      #
      # setToInvalidList = ()->
      #   row1.get("type").set("value", "select_one badlist")
      # expect(setToInvalidList).toThrow()
      ``
  describe "groups", ->
    it "can add a group", ->
      @pizzaSurvey.addRow type: "text", name: "pizza", hint: "pizza", label: "pizza"
      expect(@pizzaSurvey.rows.last() instanceof XLF.Row).toBe(true)
      expect(@pizzaSurvey.rows.length).toBe(2)
      @pizzaSurvey.addRow type: "group", name: "group"
      expect(@pizzaSurvey.rows.length).toBe(3)
      grp = @pizzaSurvey.rows.last()
      expect(grp instanceof XLF.RowError).toBe(true)
  describe "automatic naming", ->
    it "can import questions without names", ->
      survey = @createSurvey([
        "text,,\"Label with no name\""
        ])
      expect(survey.rows.at(0)?.get("name").getValue()).not.toBeTruthy()
    it "can finalize survey and generate names", ->
      survey = @createSurvey([
        "text,,\"Label with no name\""
        ])
      expect(survey.rows.at(0)?.get("name").getValue()).not.toBeTruthy()
      survey.rows.at(0).finalize()
      expect(survey.rows.at(0)?.get("name").getValue()).toBe("Label_with_no_name")
    it "increments names that are already taken", ->
      survey = @createSurvey([
        "text,question_one,\"already named question_one\"",
        "text,,\"question one\""
        ])
      # as imported
      expect(survey.rows.at(0)?.get("name").getValue()).toBe("question_one")
      # incremented from other question
      expect(survey.finalize().rows.at(1)?.get("name").getValue()).toBe("question_one_001")

    it "options automatically named", ->
      options_survey = @createSurvey([
              "text,question_one,\"already named question_one\"",
              "\"select_one abc\",abc,\"alphabet question\""
              ], [
                "abc,,\"Letter A\"",
                "abc,,\"Letter A\"",
                "abc,,\"Letter A\""
              ])
      rr = options_survey.rows.at(1)
      list = rr.getList()
      expect(list).toBeDefined()

      # automatic option names are triggered / set in "finalize()"
      list.finalize()

      [opt1, opt2, opt3] = list.options.models

      expect(opt1.get("name")).toBe("letter_a")
      expect(opt2.get("name")).toBe("letter_a_1")
      expect(opt3.get("name")).toBe("letter_a_2")
    it "properly handles boolean values (e.g. required)", ->
      rqSurvey = XLF.createSurveyFromCsv REQ_Q_SURVEY
      expect(rqSurvey.rows.at(0).getValue("required")).toBe("true")
      # when implementing XLF.configs.truthyValues into the model,
      # we may want to have converted the string value to boolean by now:
      # expect(rqSurvey.rows.at(0).getValue("required")).toBe(true)

    it "uses a proper name sluggification", ->
      expect(XLF.sluggifyLabel("asdf jkl")).toBe("asdf_jkl")
      expect(XLF.sluggifyLabel("asdf", ["asdf"])).toBe("asdf_001")
      expect(XLF.sluggifyLabel("2. asdf")).toBe("_2_asdf")
      expect(XLF.sluggifyLabel("2. asdf", ["_2_asdf"])).toBe("_2_asdf_001")
      expect(XLF.sluggifyLabel(" hello ")).toBe("hello")

  describe "lists", ->
    it "can change a list for a question", ->
      # add a new list. "yes, no, maybe"
      @pizzaSurvey.choices.add(name: "yes_no_maybe")
      ynm = @pizzaSurvey.choices.get("yes_no_maybe")
      expect(ynm).toBeDefined()

      # test original state
      firstRow = @pizzaSurvey.rows.first()
      expect(firstRow.getList().get("name")).toBe("yes_no")

      # change the list for first question to be "yes_no_maybe" instead of "yes_no"
      expect(firstRow.getList().get("name")).toBe("yes_no")
      firstRow.setList(ynm)
      expect(firstRow.getList().get("name")).toBe("yes_no_maybe")

      # change it back
      firstRow.setList("yes_no")
      expect(firstRow.getList().get("name")).toBe("yes_no")

      # cannot change it to a nonexistant list
      expect(-> firstRow.setList("nonexistant_list")).toThrow()

      # changing name of list object will not unlink the list
      list = firstRow.getList()
      list.set("name", "no_yes")
      expect(firstRow.getList()).toBeDefined()
      expect(firstRow.getList()?.get("name")).toBe("no_yes")


    it "can change options for a list", ->
      yn = @pizzaSurvey.choices.get("yes_no")
      expect(yn.options).toBeDefined()

      @pizzaSurvey.choices.add(name: "yes_no_maybe")
      ynm = @pizzaSurvey.choices.get("yes_no_maybe")
      expect(ynm).toBeDefined()

      expect(ynm.options.length).toBe(0)
      ynm.options.add name: "maybe", label: "Maybe"
      ynm.options.add [{name: "yes", label: "Yes"}, {name: "no", label: "No"}]
      expect(ynm.options.length).toBe(3)

  describe "census xlform", ->
    beforeEach ->
      @census = XLF.createSurveyFromCsv(CENSUS_SURVEY)
    it "looks good", ->
      expect(@census).toBeDefined()

  describe "question name gets updated on change", ->
    it "has skip logic", ->
      expect(@pizzaSurvey.rows.length).toBe(1)

###
Misc data. (basically fixtures for the tests above)
###
LISTS =
  yes_no:
    name: "yes_no"
    options: [
      {"list name": "yes_no", name: "yes", label: "Yes"},
      {"list name": "yes_no", name: "no", label: "No"}
    ]
  gender:
    name: "gender"
    options: [
      {"list name": "gender", name: "f", label: "Female"},
      {"list name": "gender", name: "m", label: "Male"}
    ]

PIZZA_SURVEY = """
  survey,,,
  ,type,name,label
  ,select_one yes_no,likes_pizza,Do you like pizza?
  choices,,,
  ,list name,name,label
  ,yes_no,yes,Yes
  ,yes_no,no,No
  """

CENSUS_SURVEY = """
  "survey","type","name","label"
  ,"integer","q1","How many people were living or staying in this house, apartment, or mobile home on April 1, 2010?"
  ,"select_one yes_no","q2","Were there any additional people staying here April 1, 2010 that you did not include in Question 1?"
  ,"select_one ownership_type or_other","q3","Is this house, apartment, or mobile home: owned with mortgage, owned without mortgage, rented, occupied without rent?"
  ,"text","q4","What is your telephone number?"
  ,"text","q5","Please provide information for each person living here. Start with a person here who owns or rents this house, apartment, or mobile home. If the owner or renter lives somewhere else, start with any adult living here. This will be Person 1. What is Person 1's name?"
  ,"select_one male_female","q6","What is Person 1's sex?"
  ,"date","q7","What is Person 1's age and Date of Birth?"
  ,"text","q8","Is Person 1 of Hispanic, Latino or Spanish origin?"
  ,"text","q9","What is Person 1's race?"
  ,"select_one yes_no","q10","Does Person 1 sometimes live or stay somewhere else?"
  "choices","list name","name","label"
  ,"yes_no","yes","Yes"
  ,"yes_no","no","No"
  ,"male_female","male","Male"
  ,"male_female","female","Female"
  ,"ownership_type","owned_with_mortgage","owned with mortgage",
  ,"ownership_type","owned_without_mortgage","owned without mortgage"
  ,"ownership_type","rented","rented"
  ,"ownership_type","occupied_without_rent","occupied without rent"
  "settings"
  ,"form_title","form_id"
  ,"Census Questions (2010)","census2010"
  """

REQ_Q_SURVEY = """
"survey",,,
,"type","name","label","required"
,text,q1,q1,"true"
"""

describe "testing the view", ->
  beforeEach ->
    $(".test-div").remove()
    @createSurveyViewFromCsv = (surveyCsv)=>
      @survey = XLF.createSurveyFromCsv surveyCsv
      @xlv = new SurveyApp survey: @survey
      mockNgScope(@xlv)
      @$el = @xlv.render().$el
      @_div = $("<div>", class: "test-div", html: @$el).appendTo("body")

    @createPizzaSurvey = ()=>
      @createSurveyViewFromCsv(PIZZA_SURVEY)

  afterEach ->
    # comment this next line out to see the last resulting SurveyApp element.
    @_div.remove()

  it "builds the view", ->
    @createPizzaSurvey()
    expect(@_div.find("li.xlf-row-view").length).toBe(1)

    lastRowEl = @_div.find("li.xlf-row-view").eq(0)

    # adds row selector
    clickNewRow = ()->
      lastRowEl.find(".add-row-btn").click()

    expect(clickNewRow).not.toThrow()
    expect(lastRowEl.find(".line").eq(-1).hasClass("expanded")).toBeTruthy()
    closeButton = lastRowEl.find(".line.expanded").find(".js-close-row-selector")
    expect(closeButton.length).toBe(1)
    closeButton.click()
    clickNewRow()
    lastRowEl.find(".line.expanded").find(".questiontypelist__item[data-menu-item='geopoint']").trigger("click")

    # when the event is triggered twice this next test will fail.
    expect(@_div.find("li.xlf-row-view").length).toBe(2)

  describe "properly handles boolean values (e.g. required) in the view", ->
    beforeEach ->
      @createSurveyViewWithReqVariation = (reqVariation)=>
        survCsv = REQ_Q_SURVEY.replace('"true"', reqVariation)
        @createSurveyViewFromCsv survCsv
    it 'works with "true"', ->
      @createSurveyViewWithReqVariation('"true"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(true)
    it 'works with "True"', ->
      @createSurveyViewWithReqVariation('"True"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(true)
    it 'works with "yes"', ->
      @createSurveyViewWithReqVariation('"yes"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(true)
    it 'works with "FaLsE"', ->
      @createSurveyViewWithReqVariation('"FaLsE"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(false)
    it 'works with "no"', ->
      @createSurveyViewWithReqVariation('"no"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(false)
    it 'is changed and exports properly', ->
      @createSurveyViewWithReqVariation('"yes"')
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(true)
      @_div.find(".js-advanced-toggle").eq(0).click()
      @_div.find(".xlf-dv-required input").click()
      expect(@_div.find(".xlf-dv-required input").prop("checked")).toBe(false)
      surveyCsvJson = @survey.toCsvJson()
      expect(surveyCsvJson.survey.rowObjects[0].required).toBe(XLF.configs.boolOutputs.false)

  it "changes values inside the skip logic dropdowns", ->
    @createPizzaSurvey()
    expect(@survey.rows.length).toBe(1)
    expect(@$el.find(".xlf-row-view").length).toBe(1)
    firstRowEl = @_div.find("li.xlf-row-view").eq(-1)

    # adds row selector
    $(".add-row-btn", firstRowEl).click()
    $(".questiontypelist__item[data-menu-item='text']", firstRowEl).click()
    lastRowEl = @_div.find("li.xlf-row-view").eq(-1)
    $(".js-advanced-toggle", lastRowEl).eq(0).click()
    expect(if $(".xlf-dv-relevant", lastRowEl).length is 1 then "relevant rendered" else "relevant not rendered").toBe("relevant rendered")
    $(".xlf-dv-relevant button", lastRowEl).eq(0).click()
    $(".skiplogic__addcriterion", lastRowEl).eq(0).click()
    slList = $(".skiplogic__criterialist", lastRowEl)
    select = $("select.skiplogic__rowselect", slList).eq(0)
    opt1 = select.find("option").eq(1)
    # label changing is no longer done this way:
    # expect(opt1.prop("value")).toBe("likes_pizza")
    # row1 = @survey.rows.at(0)
    # row1.get("name").set("value", "different_name")
    # row1.get("label").set("value", "A different label")
    # expect($("select.skiplogic__rowselect", slList).find("option").eq(1).prop("value")).toBe("different_name")


describe "reorder items by id", ->
  it "works as it should", ->
    wrap = $("<div>")
    vals = [0..10]
    vals.sort -> return 0.5 - Math.random()
    for val in vals
      $("<p>", text: "P").attr("data-sort-by-value", val).appendTo(wrap)
    viewUtils.reorderElemsByData "p", wrap, "sort-by-value"
    reorderedVals = ($(p).data("sort-by-value") for p in wrap.find("p"))
    expect(reorderedVals).toEqual([0..10])


unknownTypeString = "unktype"
ERRONEOUS_CSV = """
"survey","type","name","label"
,"text","test_q","text question"
,"#{unknownTypeString}","unktype_name","unktype label"
,"text","test_q2","text question 2"
"""

setupView = (survey)->
  xlv = new SurveyApp(survey: @survey).render()
  mockNgScope(xlv)
  $("<div>", class: "test-div", html: xlv.$el).appendTo("body")

mockNgScope = (surveyApp)->
  surveyApp.ngScope = do ->
    # mock ngScope
    displayQlib: false

teardownView = ->
  $(".test-div").remove()
  ``
###
This needs to pass for 509

describe "properly handle erroneous rows", ->
  beforeEach ->
    XLF.ignoreConsoleErrors = true
    @survey = XLF.createSurveyFromCsv(ERRONEOUS_CSV)
  it "imports the erroneous row", ->
    expect(@survey.rows.length).toBe(3)
    expect(@survey.rows.at(1) instanceof XLF.RowError).toBeTruthy()

  it "displays the erroneous row as a rowerror", ->
    div = setupView(@survey)
    expect(div.find(".xlf-row-view--error").length).toBe(1)
    teardownView()

  it "still exports the erroneous row", ->
    expect(@survey.toCsvJson().survey.rowObjects.length).toBe(3)
    errorRowOutput = @survey.toCsvJson().survey.rowObjects[1]
    expect(errorRowOutput.type).toBe(unknownTypeString)
###