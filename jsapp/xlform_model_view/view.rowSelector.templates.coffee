define 'cs!xlform/view.rowSelector.templates', [], ()->
  xlfRowSelector = {}

  closeRowSelectorButton = """
      <button type="button" class="row__questiontypes__close js-close-row-selector shrink pull-right close close-button close-button--depr" aria-hidden="true">&times;</button>
  """

  xlfRowSelector.line = () ->
      """
          <div class="row__questiontypes row-fluid clearfix">
            #{closeRowSelectorButton}
            <h4 class="menu-title">Choose question type</h4>
            <div class="row__questiontypes__list clearfix"></div>
            <div>
              Or
              <button class="menu-title btn rowselector_openlibrary">Add from Question Library</button>
            </div>
          </div>
      """

  xlfRowSelector.cell = (atts) ->
      """
        <div class="questiontypelist__item" data-menu-item="#{atts.id}">
          <i class="fa fa-#{atts.faClass} fa-fw"></i>
          #{atts.label}
        </div>
      """

  xlfRowSelector
