@viewTemplates = {}

viewTemplates.xlfDetailView = (that) ->
    """
    <code>#{that.model.key}:</code>
    <code>#{that.model.get("value")}</code>
    """

viewTemplates.xlfRowSelector = {}

viewTemplates.xlfRowSelector.line = () ->
    """
      <div class="iwrap">
        <div class="well row-fluid clearfix">
          <button type="button" class="shrink pull-right close" aria-hidden="true">&times;</button>
          <h4>Choose question type</h4>
        </div>
      </div>
    """

viewTemplates.xlfRowSelector.cell = (atts) ->
    """
      <div class="card menu-item" data-menu-item="#{atts.id}">
        <i class="fa fa-#{atts.faClass} fa-fw"></i>
        #{atts.label}
      </div>
    """

viewTemplates.xlfListView = {}

viewTemplates.xlfListView.addOptionButton = () ->
    """<button class="btn btn-xs btn-default">Add option</button>"""

viewTemplates.xlfRowView = () ->
    """
    <div class="card">
      <h4 class="card__header">
        <i class="fa fa-fw card__header-icon"></i>
        <span class="card__header-title">Label goes here</span>
      </h4>
      <button type="button" class="close delete-row card__close-button js-delete-row" aria-hidden="true">&times;</button>
      <div class="row list-view hidden">
        <ul></ul>
      </div>
      <div class="row-fluid clearfix advanced-details">
        <div class="row-extras advanced-details__content hidden row-fluid">
          <p class="pull-left">
            <span class="fa fa-cog fa-fw row-extras__cog js-advanced-toggle"></span>
          </p>
        </div>
        <div class="row-extras-summary advanced-details__content-summary js-advanced-toggle">
          <span class="fa fa-cog fa-fw row-extras__cog-faded"></span>
          <span class="adv-details-txt">Advanced question details</span>
        </div>
      </div>
    </div>
    <div class="row clearfix expanding-spacer-between-rows">
      <div class="add-row-btn  btn  btn--block  btn-xs  btn-default"><i class="fa  fa-plus"></i></div>
      <div class="line">&nbsp;</div>
    </div>
    """

viewTemplates.surveyTemplateApp = () ->
    """
        <button class="btn--start-from-scratch btn">Start From Scratch</button>
        <span class="or">or</span>
        <hr>
        <div class="choose-template">
            <h3>Choose Template</h3>
        </div>
    """

viewTemplates.surveyApp = (survey) ->
    """
      <div class="sub-header-bar">
        <button class="btn  btn--utility" id="xlf-export">Export and clone</button>
        <button class="btn  btn--utility" id="save">Save</button>
        <button class="btn  btn--utility" id="xlf-preview">Preview</button>
        <button class="btn  btn--utility  pull-right" id="xlf-group">Group questions</button>
        <button class="btn  btn--utility  pull-right" id="xlf-repeat">Repeat questions</button>
      </div>
      <header class="survey-header">
        <p class="survey-header__description" hidden>
        <hgroup class="survey-header__inner">
          <h1 class="survey-header__title  form-title">
            #{survey.settings.get("form_title")}
          </h1>
          <h2 class="survey-header__hashtag  form-id">#{survey.settings.get("form_id")}</h2>
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

viewTemplates.xlfSurveyDetailView = (model) ->
    """
    <label title="#{model.get("description") || ''}">
      <input type="checkbox">
      #{model.get("label")}
    </label>
    """