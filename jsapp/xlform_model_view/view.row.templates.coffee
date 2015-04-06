define 'cs!xlform/view.row.templates', [], ()->
  expandingSpacerHtml = """
      <div class="survey__row__spacer  row clearfix expanding-spacer-between-rows expanding-spacer-between-rows--depr">
        <div class="js-expand-row-selector btn btn--addrow btn--block  btn-xs  btn-default  add-row-btn"
            ><i class="fa fa-plus"></i></div>
        <div class="line">&nbsp;</div>
      </div>
  """

  groupSettingsView = ->
    """
      <section class="card__settings  row-extras row-extras--depr">
        <i class="card__settings-close fa fa-times js-toggle-card-settings"></i>
        <ul class="card__settings__tabs">
          <li class="heading"><i class="fa fa-cog"></i> Settings</li>
          <li data-card-settings-tab-id="all" class="card__settings__tabs__tab--active">All group settings</li>
          <li data-card-settings-tab-id="skip-logic" class="">Skip Logic</li>
        </ul>
        <div class="card__settings__content">
          <div class="card__settings__fields card__settings__fields--active card__settings__fields--all">
          </div>
          <div class="card__settings__fields card__settings__fields--skip-logic"></div>
        </div>
      </section>
    """
  rowSettingsView = ->
    """
      <section class="card__settings  row-extras row-extras--depr">
        <i class="card__settings-close fa fa-times js-toggle-card-settings"></i>
        <ul class="card__settings__tabs">
          <li class="heading"><i class="fa fa-cog"></i> Settings</li>
          <li data-card-settings-tab-id="question-options" class="card__settings__tabs__tab--active">Question Options</li>
          <li data-card-settings-tab-id="skip-logic" class="">Skip Logic</li>
          <li data-card-settings-tab-id="validation-criteria" class="">Validation Criteria</li>
          <li data-card-settings-tab-id="response-type" class="card__settings__tab--response-type">Response Type</li>
        </ul>
        <div class="card__settings__content">
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

  xlfRowView = (surveyView) ->
      template = """
      <div class="survey__row__item survey__row__item--question card js-select-row">
        <div class="card__header">
          <div class="card__header--shade"><span></span></div>
          <div class="card__indicator">
            <div class="noop card__indicator__icon"><i class="fa fa-fw card__header-icon"></i></div>
          </div>
          <div class="card__text">
            <span class="card__header-title js-cancel-select-row"></span>
          </div>
          <div class="card__buttons">
            <span class="card__buttons__button card__buttons__button--settings gray js-toggle-card-settings" data-button-name="settings"><i class="fa fa-cog"></i></span>
            <span class="card__buttons__button card__buttons__button--delete red js-delete-row" data-button-name="delete"><i class="fa fa-trash-o"></i></span>
      """
      if surveyView.features.multipleQuestions
        template += """<span class="card__buttons__button card__buttons__button--copy blue js-clone-question" data-button-name="duplicate"><i class="fa fa-copy"></i></span>
                  <span class="card__buttons__button card__buttons__button--add gray-green js-add-to-question-library" data-button-name="add-to-library"><i class="fa fa-folder-o"><i class="fa fa-plus"></i></i></span>"""

      return template + """
          </div>
        </div>
      </div>
      #{expandingSpacerHtml}
      """

  groupView = (g)->
    """
    <div class="survey__row__item survey__row__item--group group card js-select-row">
      <header class="group__header">
        <i class="group__caret js-toggle-group-expansion fa fa-fw"></i>
        <span class="group__label js-cancel-select-row">#{g.getValue('label')}</span>
          <div class="group__header__buttons">
            <span class="group__header__buttons__button group__header__buttons__button--settings  gray js-toggle-card-settings"><i class="fa fa-cog"></i></span>
            <span class="group__header__buttons__button group__header__buttons__button--delete  red js-delete-group"><i class="fa fa-trash-o"></i></span>
          </div>
      </header>
      <ul class="group__rows">
      </ul>
    </div>
    #{expandingSpacerHtml}
    """

  scoreView = (s)->
    """
    <div class="score__options">
      <p class="score__options__label--choices">
        Option labels and values
      </p>
      <ul class="score__contents score__contents--choices">
      </ul>
      <button class="score__options__button">
        + Add another option
      </button>

      <p class="score__options__label--rows">
        Questions labels and data column names
      </p>
      <ul class="score__contents score__contents--rows">
      </ul>
      <button class="score__options__button">
        + Add another rank
      </button>
    </div>
    """


  selectQuestionExpansion = ->
    """
    <div class="card--selectquestion__expansion row__multioptions js-cancel-sort">
      <div class="list-view">
        <ul></ul>
      </div>
    </div>
    """

  expandChoiceList = ()->
    """
    <span class="card__buttons__multioptions js-toggle-row-multioptions js-cancel-select-row"><i class="fa fa-fw caret"></i></span>
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
  scoreView: scoreView
  groupSettingsView: groupSettingsView
  rowSettingsView: rowSettingsView
