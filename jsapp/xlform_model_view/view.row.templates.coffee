define 'cs!xlform/view.row.templates', [], ()->
  expandingSpacerHtml = """
      <div class="survey__row__spacer row clearfix expanding-spacer-between-rows">
        <div class="add-row-btn js-expand-row-selector btn  btn--block  btn-xs  btn-default"><i class="fa fa-plus"></i></div>
        <div class="line">&nbsp;</div>
      </div>
  """

  # deleteRowButton = """
  #     <button type="button" class="close delete-row close-button js-delete-row" aria-hidden="true">&times;</button>
  # """

  xlfRowView = () ->
      """
      <div class="survey__row__item survey__row__item--question card">
        <div class="card__header">
          <div class="card__indicator">
            <div class="noop card__indicator__icon"><i class="fa fa-fw card__header-icon"></i></div>
          </div>
          <div class="card__text">
            <span class="card__header-title"></span>
          </div>

          <div class="card__buttons">
            <span class="card__buttons__button gray js-advanced-toggle"><i class="fa fa-cog"></i></span>
            <span class="card__buttons__button red js-delete-row"><i class="fa fa-trash-o"></i></span>
            <span class="card__buttons__button blue hidden"><i class="fa fa-copy"></i></span>
            <span class="card__buttons__button gray-green js-add-to-question-library"><i class="fa fa-folder-o"><i class="fa fa-plus"></i></i></span>

          </div>
        </div>
        <div class="advanced-details">
          <div class="row-extras card__settings advanced-details__content">
          </div>
        </div>
      </div>
      #{expandingSpacerHtml}
      """

  groupView = (g)->
    """
    <div class="survey__row__item survey__row__item--group group">
      <header class="group__header">
        <i class="group__carat js-toggle-group-expansion fa fa-fw"></i>
        <span class="group__name">#{g.getValue('label')}</span>
          <div class="group__header__buttons">
            <span class="group__header__buttons__button gray js-advanced-toggle"><i class="fa fa-cog"></i></span>
            <span class="group__header__buttons__button red js-delete-group"><i class="fa fa-trash-o"></i></span>
          </div>
      </header>
      <section class="group__settings"></section>
      <ul class="group__rows"></ul>
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
    <span class="card__buttons__multioptions js-expand-multioptions"><i class="fa fa-fw caret"></i></span>
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
