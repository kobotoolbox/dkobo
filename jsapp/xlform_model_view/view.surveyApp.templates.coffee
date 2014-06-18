define 'cs!xlform/view.surveyApp.templates', [], ()->

  surveyTemplateApp = () ->
      """
          <button class="btn js-start-survey">Start from Scratch</button>
          <span class="or">or</span>
          <hr>
          <form action="/import_survey_draft" class="btn btn--fileupload js-import-fileupload">
            <span class="fileinput-button">
              <span>Import XLS</span>
              <input type="file" name="files">
            </span>
          </form>
      """

  surveyApp = (surveyApp) ->
      survey = surveyApp.survey
      multiple_questions = surveyApp.features.multipleQuestions
      if multiple_questions
        type_name = "Survey"
      else
        type_name = "Question"
      """
        <div class="sub-header-bar">
          <div class="container__wide">
            <button class="btn btn--utility survey-editor__action--multiquestion" id="settings"><i class="fa fa-cog"></i> Form Settings</button>
            <button class="btn btn--utility" id="save"><i class="fa fa-check-circle green"></i> Save #{type_name}</button>
            <button class="btn btn--utility" id="xlf-preview"><i class="fa fa-eye"></i> Preview #{type_name}</button>
            <button class="btn btn--utility survey-editor__action--multiquestion js-expand-multioptions--all" ><i class="fa fa-eye"></i> Expand All Questions</button>
            <button class="btn btn--utility survey-editor__action--multiquestion btn--group-questions btn--disabled js-group-rows">Group Questions</button>
          <button class="btn btn--utility pull-right survey-editor__action--multiquestion rowselector_toggle-library" id="question-library"><i class="fa fa-folder"></i> Question Library</button>
          </div>
        </div>
        <div class="container__fixed">
          <div class="container__wide">
          <div class="survey-header__options container">
            <h4 class="survey-header__options-table-title">Form settings</h4>
            <table class="survey-header__options-table">
              <tr>
                <td><span>Form ID</span></td>
                <td><span class="form-id  editable  editable-click">#{survey.settings.get("form_id")}</span></td>
                <td><span>(Unique form name)</span></td>
              </tr>
              <tr>
                <td><span>Automatic IDs</span></td>
                <td><span class="editable  editable-click">Standard mode</span></td>
                <td><span>(Choose Statistics mode for question IDs like A01, A02, etc.)</span></td>
              </tr>
              <tr>
                <td><span>Version</span></td>
                <td><span class="editable  editable-click">1.0</span></td>
                <td><span>(Any version number you'd like to include with the form - optional)</span></td>
              </tr>
              <tr>
                <td><span>Form Language</span></td>
                <td><span class="editable  editable-click">English</span></td>
                <td><span>(The default language in which the form is written - optional)</span></td>
              </tr>
              <tr>
                <td><span>Public Key</span></td>
                <td><span class="editable  editable-click">[blank]</span></td>
                <td><span>(The encryption key used for secure forms - optional)</span></td>
              </tr>
              <tr>
                <td><span>Submission URL</span></td>
                <td><span class="editable  editable-click">[blank]</span></td>
                <td><span>(The specific server instance where the data should go to - optional)</span></td>
              </tr>
            </table>
            <h4 class="survey-header__options-table-title">Hidden meta questions to include in your form to help with analysis</h4>
            <div class="stats  row-details" id="additional-options"></div>
          </div>          </div>
        </div>
        <header class="survey-header">
          <p class="survey-header__description" hidden>
            <hgroup class="survey-header__inner container">
              <h1 class="survey-header__title">
                <span class="form-title">#{survey.settings.get("form_title")}</span>
              </h1>
            </hgroup>
          </p>
        </header>
        <div class="survey-editor form-editor-wrap container">
          <ul class="-form-editor survey-editor__list">
            <li class="survey-editor__null-top-row empty">
              <p class="survey-editor__message well">
                <b>This form is currently empty.</b><br>
                You can add questions, notes, prompts, or other fields by clicking on the "+" sign below.
              </p>
              <div class="survey__row__spacer  expanding-spacer-between-rows expanding-spacer-between-rows--depr">
                <div class="btn btn--block btn--addrow js-expand-row-selector   add-row-btn add-row-btn--depr">
                  <i class="fa fa-plus"></i>
                </div>
                <div class="line">&nbsp;</div>
              </div>
            </li>
          </ul>
        </div>
      """

  surveyTemplateApp: surveyTemplateApp
  surveyApp: surveyApp
