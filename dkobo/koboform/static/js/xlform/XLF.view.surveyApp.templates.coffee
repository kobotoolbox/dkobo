viewTemplates.surveyTemplateApp = () ->
    """
        <button class="btn">Start from Scratch</button>
        <span class="or">or</span>
        <hr>
        <button class="btn">Import from Excel</button>
<!--
        <div class="choose-template">
            <h3>Choose Template</h3>
        </div>
-->
    """

viewTemplates.surveyApp = (survey) ->
    """
      <div class="sub-header-bar">
        <button class="btn  btn--utility" id="xlf-export">Export and clone</button>
        <button class="btn  btn--utility" id="save">Save</button>
        <a class="btn  btn--utility" id="xlf-download" href="#">Download</a>
        <button class="btn  btn--utility" id="xlf-preview">Preview</button>
        <button class="btn  btn--utility  pull-right" id="xlf-group">Group questions</button>
        <button class="btn  btn--utility  pull-right" id="xlf-repeat">Repeat questions</button>
      </div>
      <header class="survey-header">
        <p class="survey-header__description" hidden>
        <hgroup class="survey-header__inner">
          <h1 class="survey-header__title">
            <span class="form-title">#{survey.settings.get("form_title")}</span>
          </h1>
          <h2 class="survey-header__hashtag">
            <span class="form-id">#{survey.settings.get("form_id")}</span>
          </h2>
        </hgroup>
        </p>
        <div class="survey-header__options  well  stats  row-details" id="additional-options"></div>
      </header>
      <div class="survey-editor  form-editor-wrap">
        <ul class="-form-editor">
          <li class="editor-message empty">
            <p class="survey-editor__message  well">
              <b>This survey is currently empty.</b><br>
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
    """
