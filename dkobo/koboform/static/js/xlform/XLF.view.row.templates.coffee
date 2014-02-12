viewTemplates.xlfRowView = () ->
    """
    <div class="card">
      <h4 class="card__header">
        <i class="fa fa-fw card__header-icon"></i>
        <span class="card__header-title">Label goes here</span>
      </h4>
      <button type="button" class="close delete-row close-button js-delete-row" aria-hidden="true">&times;</button>
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

viewTemplates.rowErrorView = (atts)->
  """
  <div class="card card-error">
    <button type="button" class="close delete-row close-button js-delete-row" aria-hidden="true">&times;</button>
    Row could not be displayed: <pre>#{atts}</pre>
    <em>This question could not be imported. Please re-create it manually. Please contact us at <a href="mailto:info@kobotoolbox.org">info@kobotoolbox.org</a> so we can fix this bug!</em>
  </div>
  <div class="row clearfix expanding-spacer-between-rows">
    <div class="add-row-btn  btn  btn--block  btn-xs  btn-default"><i class="fa  fa-plus"></i></div>
    <div class="line">&nbsp;</div>
  </div>
  """
