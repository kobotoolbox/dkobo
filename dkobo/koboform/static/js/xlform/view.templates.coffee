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
          <h4>Please select a type for the new question</h4>
        </div>
      </div>
    """

viewTemplates.xlfRowSelector.cell = (mcell) ->
    """
        <div 
            class="menu-item menu-item-#{mcell}" 
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
      <div class="row clearfix">
        <div class="col-md-8">
          <h1 class="title">
            <span class="display-title">
              #{survey.get("displayTitle")}
            </span>
            <span class="hashtag">[<span class="form-name">#{survey.settings.get("form_title")}</span>]</span>
          </h1>
          <p class="display-description" style="visibility: hidden;">
            #{survey.get("displayDescription")}
          </p>
        </div>
        <div class="col-md-4 buttons">
          <button id="save" class="btn">Save</button>
        </div>
        <div class="stats row-details clearfix col-md-11" id="additional-options"></div>
      </div>
      <div class="form-editor-wrap">
        <ul class="-form-editor">
          <li class="editor-message empty">
            <p class="empty-survey-text">
              <strong>This survey is currently empty.</strong><br>
              You can add questions, notes, prompts, or other fields by clicking on the "+" sign below.
            </p>
            <div class="row clearfix expanding-spacer-between-rows">
              <div class="add-row-btn btn btn-xs btn-default">+</div>
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