###
Do not add tests to this file.
They are only used for refactoring.
They do not work in the karma runner.
###

unless @__karma__
  describe "testing the view", ->

    xlf = dkobo_xlform

    mockNgScope = (surveyApp)->
      surveyApp.ngScope = do ->
        # mock ngScope
        displayQlib: false

    it "has jquery", ->
      expect(jQuery).not.toBeUndefined()
      expect(jQuery).toBe($)
   
    beforeEach ->
      $(".test-div").remove()
      @createSurveyViewFromCsv = (surveyCsv)=>
        @survey = xlf.model.Survey.load surveyCsv
        @xlv = new xlf.view.SurveyApp survey: @survey
        mockNgScope(@xlv)
        @$el = @xlv.render().$el
        @_div = $("<div>", class: "test-div", html: @$el).appendTo("body")

      @createPizzaSurvey = ()=>
        @createSurveyViewFromCsv(PIZZA_SURVEY)

    afterEach ->
      # comment this next line out to see the last resulting SurveyApp element.
      $(".test-div").remove()

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
        expect(surveyCsvJson.survey.rowObjects[0].required).toBe(xlf.model.configs.boolOutputs.false)

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
      xlf.view.utils.reorderElemsByData "p", wrap, "sort-by-value"
      reorderedVals = ($(p).data("sort-by-value") for p in wrap.find("p"))
      expect(reorderedVals).toEqual([0..10])


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

unknownTypeString = "unktype"

ERRONEOUS_CSV = """
"survey","type","name","label"
,"text","test_q","text question"
,"#{unknownTypeString}","unktype_name","unktype label"
,"text","test_q2","text question 2"
"""
