define 'cs!xlform/view.rowSelector.templates', [], ()->
  xlfRowSelector = {}

  closeRowSelectorButton = """
      <button type="button" class="close-button js-close-row-selector shrink pull-right close" aria-hidden="true">&times;</button>
  """

  xlfRowSelector.line = () ->
      """
          <div class="row__questiontypes row-fluid clearfix">
            #{closeRowSelectorButton}
            <h4 class="menu-title">Choose question type</h4>
            <div class="rowselector__questiontypes"></div>
            <p style="clear:both">
              Or
              <button class="menu-title btn rowselector_openlibrary">Add from Question Library</button>
            </p>
          </div>
      """

  xlfRowSelector.cell = (atts) ->
      """
        <div class="menu-item" data-menu-item="#{atts.id}">
          <i class="fa fa-#{atts.faClass} fa-fw"></i>
          #{atts.label}
        </div>
      """

  xlfRowSelector
