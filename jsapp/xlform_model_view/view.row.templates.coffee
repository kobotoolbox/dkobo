define 'cs!xlform/view.row.templates', [], ()->
  expandingSpacerHtml = """
      <div class="row clearfix expanding-spacer-between-rows">
        <div class="add-row-btn js-expand-row-selector btn  btn--block  btn-xs  btn-default"><i class="fa  fa-plus"></i></div>
        <div class="line">&nbsp;</div>
      </div>
  """

  # deleteRowButton = """
  #     <button type="button" class="close delete-row close-button js-delete-row" aria-hidden="true">&times;</button>
  # """

  xlfRowView = () ->
      """
      <div class="card">
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
            <span class="card__buttons__button blue"><i class="fa fa-copy"></i></span>
          </div>
        </div>
        <div class="card__expanded">
          <div class="row list-view hidden">
            <ul></ul>
          </div>
        </div>
        <div class="row-fluid clearfix advanced-details">
          <div class="row-extras advanced-details__content hidden row-fluid">
            <p class="pull-left">
              <!-- <span class="fa fa-cog fa-fw row-extras__cog js-advanced-toggle"></span> -->
            </p>
          </div>
          <div class="row-extras-summary advanced-details__content-summary js-advanced-toggle">
          </div>
        </div>
        <div class="pull-right row-extras__add-to-question-library">
          <span class="fa fa-plus-square-o fa-fw"></span>
          <span class="row-extras__add-to-question-library--text">Copy to Library</span>
        </div>
      </div>
      #{expandingSpacerHtml}
      """

  rowErrorView = (atts)->
    """
    <div class="card card--error">
      #{deleteRowButton}
      Row could not be displayed: <pre>#{atts}</pre>
      <em>This question could not be imported. Please re-create it manually. Please contact us at <a href="mailto:info@kobotoolbox.org">info@kobotoolbox.org</a> so we can fix this bug!</em>
    </div>
    #{expandingSpacerHtml}
    """

  xlfRowView: xlfRowView
  rowErrorView: rowErrorView
