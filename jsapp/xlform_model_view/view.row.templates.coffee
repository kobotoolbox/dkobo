define 'cs!xlform/view.row.templates', [], ()->
  expandingSpacerHtml = """
      <div class="survey__row__spacer  row clearfix expanding-spacer-between-rows expanding-spacer-between-rows--depr">
        <div class="js-expand-row-selector btn btn--addrow btn--block  btn-xs  btn-default  add-row-btn"
            ><i class="fa fa-plus"></i></div>
        <div class="line">&nbsp;</div>
      </div>
  """

  # deleteRowButton = """
  #     <button type="button" class="close delete-row close-button js-delete-row" aria-hidden="true">&times;</button>
  # """

  settingsView = (forWhat, blockName)->
    if forWhat == 'group'
      return """
      <section class="#{blockName}  row-extras row-extras--depr">
        <ul class="#{blockName}__tabs">
          <li class="heading"><i class="fa fa-cog"></i> Settings</li>
          <li>All #{forWhat} settings</li>
          <!--
          <li data-card-settings-tab-id="question-options">Question Options</li>
          <li data-card-settings-tab-id="skip-logic" class="">Skip Logic</li>
          <li data-card-settings-tab-id="validation-criteria" class="">Validation Criteria</li>
          <li data-card-settings-tab-id="response-type" class="">Response Type</li>
          -->
        </ul>
        <div class="#{blockName}__content">
        </div>
      </section>
      """
    else
      return """
      <section class="#{blockName}  row-extras row-extras--depr">
        <ul class="#{blockName}__tabs">
          <li class="heading"><i class="fa fa-cog"></i> Settings</li>
          <li data-card-settings-tab-id="question-options">Question Options</li>
          <li data-card-settings-tab-id="skip-logic" class="">Skip Logic</li>
          <li data-card-settings-tab-id="validation-criteria" class="">Validation Criteria</li>
          <li data-card-settings-tab-id="response-type" class="">Response Type</li>
        </ul>
        <div class="#{blockName}__content">
          <ul class="card__settings__fields card__settings__fields--active card__settings__fields--question-options">
          </ul>

          <ul class="card__settings__fields card__settings__fields--skip-logic">
          </ul>

          <ul class="card__settings__fields card__settings__fields--validation-criteria">
          </ul>

          <ul class="card__settings__fields card__settings__fields--response-type">
          </ul>
        </div>
      </section>
      """

  xlfRowView = () ->
      """
      <div class="survey__row__item survey__row__item--question card js-select-row">
        <div class="card__header">
          <div class="card__indicator">
            <div class="noop card__indicator__icon"><i class="fa fa-fw card__header-icon"></i></div>
          </div>
          <div class="card__text">
            <span class="card__header-title"></span>
          </div>
          <div class="card__buttons">
            <span class="card__buttons__button card__buttons__button--settings gray js-advanced-toggle js-toggle-row-settings"><i class="fa fa-cog"></i></span>
            <span class="card__buttons__button card__buttons__button--delete red js-delete-row"><i class="fa fa-trash-o"></i></span>
            <span class="card__buttons__button card__buttons__button--copy blue hidden"><i class="fa fa-copy"></i></span>
            <span class="card__buttons__button gray-green js-add-to-question-library"><i class="fa fa-folder-o"><i class="fa fa-plus"></i></i></span>
          </div>
        </div>
        #{settingsView('question', 'card__settings')}
      </div>
      #{expandingSpacerHtml}
      """

  groupView = (g)->
    """
    <div class="survey__row__item survey__row__item--group group js-select-row">
      <header class="group__header">
        <i class="group__caret js-toggle-group-expansion fa fa-fw"></i>
        <span class="group__label">#{g.getValue('label')}</span>
          <div class="group__header__buttons">
            <span class="group__header__buttons__button group__header__buttons__button--settings  gray js-toggle-group-settings"><i class="fa fa-cog"></i></span>
            <span class="group__header__buttons__button group__header__buttons__button--delete  red js-delete-group"><i class="fa fa-trash-o"></i></span>
          </div>
      </header>
      #{settingsView('group', 'card__settings')}
      <ul class="group__rows">
      </ul>
    </div>
    #{expandingSpacerHtml}
    """

  selectQuestionExpansion = ->
    """
    <div class="card--selectquestion__expansion row__multioptions">
      <div class="list-view">
        <ul></ul>
      </div>
    </div>
    """

  expandChoiceList = ()->
    """
    <span class="card__buttons__multioptions js-toggle-row-multioptions"><i class="fa fa-fw caret"></i></span>
    """

  rowErrorView = (atts)->
    """
    <div class="card card--error">
      Row could not be displayed: <pre>#{atts}</pre>
      <em>This question could not be imported. Please re-create it manually. Please contact us at <a href="mailto:info@kobotoolbox.org">info@kobotoolbox.org</a> so we can fix this bug!</em>
    </div>
    #{expandingSpacerHtml}
    """

  xlfRowView: xlfRowView
  expandChoiceList: expandChoiceList
  selectQuestionExpansion: selectQuestionExpansion
  groupView: groupView
  rowErrorView: rowErrorView
