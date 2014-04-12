viewTemplates.surveyTemplateApp = () ->
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

viewTemplates.surveyApp = (survey) ->
    """
      <div class="sub-header-bar">
        <button class="btn  btn--utility" id="save">Save</button>
        <button class="btn  btn--utility" id="xlf-preview">Preview</button>
        <!--
        <button class="btn  btn--utility  pull-right" id="xlf-group">Group questions</button>
        <button class="btn  btn--utility  pull-right" id="xlf-repeat">Repeat questions</button>
        -->
      </div>
      <header class="survey-header">
        <p class="survey-header__description" hidden>
          <hgroup class="survey-header__inner">
            <h1 class="survey-header__title">
              <i class="survey-header__options-toggle  fa  fa-cog"></i>
              <span class="form-title">#{survey.settings.get("form_title")}</span>
            </h1>
          </hgroup>
        </p>
        <div class="survey-header__options  well">
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
        </div>
      </header>
      <div class="survey-editor  form-editor-wrap">
        <ul class="-form-editor">
          <li class="survey-editor__null-top-row empty">
            <p class="survey-editor__message well">
              <b>This form is currently empty.</b><br>
              You can add questions, notes, prompts, or other fields by clicking on the "+" sign below.
            </p>
            <div class="expanding-spacer-between-rows">
              <div class="add-row-btn  btn  btn--block">
                <i class="fa  fa-plus"></i>
              </div>
              <div class="line">&nbsp;</div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Ugly inline jQuery for quick options toggle - demo purposes only, needs to be removed -->
      <script>
        $( '.survey-header' ).on( 'click', '.survey-header__options-toggle', function() {
          $( '.survey-header__options' ).toggle();
        });
      </script>
    """
