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

viewTemplates.xlfRowSelector.cell = (mcell) ->
    """
        <div
            class="menu-item menu-item--#{mcell}"
            data-menu-item="#{mcell}">
                #{mcell}
        </div>
    """

viewTemplates.xlfListView = {}

viewTemplates.xlfListView.addOptionButton = () ->
    """<button class="btn btn-xs btn-default col-md-3 col-md-offset-1">Add option</button>"""

viewTemplates.xlfRowView = () ->
    """
      <div class="row clearfix">
        <div class="row-type-col row-type">
        </div>
        <div class="col-xs-9 col-sm-10 row-content"></div>
        <div class="col-xs-1 col-sm-1 row-r-buttons">
          <button type="button" class="close delete-row" aria-hidden="true">&times;</button>
        </div>
      </div>
      <div class="row list-view hidden">
        <ul class="col-md-offset-1 col-md-8"></ul>
      </div>
      <div class="row-fluid clearfix">
        <div class="row-type-col">&nbsp;</div>
        <p class="col-xs-11 row-extras-summary">
          <span class="glyphicon glyphicon-cog"></span> &nbsp;
          <span class="summary-details"></span>
        </p>
        <div class="col-xs-11 row-extras hidden row-fluid">
          <p class="pull-left">
            <span class="glyphicon glyphicon-cog"></span>
          </p>
        </div>
      </div>
      <div class="row clearfix expanding-spacer-between-rows">
        <div class="add-row-btn btn btn-xs btn-default">+</div>
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
        <button class="btn  btn--utility">Export and clone</button>
        <button class="btn  btn--utility">Save</button>
        <button class="btn  btn--utility">Preview</button>
        <button class="btn  btn--utility  pull-right">Group questions</button>
        <button class="btn  btn--utility  pull-right">Repeat questions</button>
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
        <div class="survey-header__actions  buttons">
          <button id="save" class="btn">Save</button>
        </div>
      </header>
      <div class="survey-editor  form-editor-wrap">
        <ul class="-form-editor">
          <li class="editor-message empty">
            <p class="survey-editor__message  well">
              <b>This survey is currently empty.</b><br>
              You can add questions, notes, prompts, or other fields by clicking on the "+" sign below.
            </p>
            <div class="expanding-spacer-between-rows">
              <div class="add-row-btn  btn">
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

###
viewTemplates.xlfManageListView = (uid) ->
    """
      <div class="form-group">
        <label for="#{uid}">From list:</label>
        <select id="#{uid}" class="form-control"></select>
      </div>
    <!--
      <div class="row-fluid clearfix">
        <div class="col-sm-4 form-group">
          <div class="row-fluid">
            <label class="control-label col-sm-5" for="#{uid}">
              Select a list:
            </label>
            <div class="col-sm-7">
              <select class="form-control" id="#{uid}"></select>
            </div>
          </div>
        </div>
      </div>
      -->
    """

viewTemplates.xlfManageListView.buttons = () ->
    """
        <button class="rename-list">rename list</button>
        <button class="cl-save">save</button>
        <button class="cl-cancel">cancel</button>
    """

viewTemplates.xlfManageListView.table = (list) ->
    """
        <table class="table-hovered table-bordered" contenteditable="true">
          <tr>
            <th colspan="2">#{list.get("name")}</th>
          </tr>
        </table>
    """

viewTemplates.xlfEditListView = (choiceList) ->
    """
      <p class="new-list-text">Name: <span class="name">#{@choiceList.get("name") || ""}</span></p>
      <div class="options"></div>
      <p><button class="list-add-row">[+] Add option</button></p>
      <p class="error" style="display:none"></p>
      <p><button class="list-ok">OK</button><button class="list-cancel">Cancel</button></p>
    """
###
