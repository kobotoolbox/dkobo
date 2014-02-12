viewTemplates.xlfRowSelector = {}

viewTemplates.xlfRowSelector.line = () ->
    """
      <div class="iwrap">
        <div class="well row-fluid clearfix">
          <button type="button" class="close-button shrink pull-right close" aria-hidden="true">&times;</button>
          <h4 class="menu-title">Choose question type</h4>
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
