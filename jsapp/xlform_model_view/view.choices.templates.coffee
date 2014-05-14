define 'cs!xlform/view.choices.templates', [], ()->

  addOptionButton = () ->
      """<div class="card__addoptions">
            <ul><li class="xlf-option-view">
              <div><span class="editable editable-click">+ Click to add another response...</span><code><label>Value:</label> <span>Automatic</span></code></div>
            </li></ul>
        </div>"""

  addOptionButton: addOptionButton