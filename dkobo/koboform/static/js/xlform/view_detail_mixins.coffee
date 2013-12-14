@DetailViewMixins = do ->
  VX = {}

  VX.type =
    html: ->
      @$el.css width: 40, height: 40
      tps = @model.get('typeId')
      @$el.attr("title", "Row Type: #{tps}")
      @$el.addClass("rt-#{tps}")
      @$el.addClass("type-icon")
    insertInDOM: (rowView)->
      rowView.$(".row-type").append(@$el)

  VX.label = VX.hint =
    html: ->
      """
      <div class="col-md-12">
        <blockquote style="display: inline-block">
          #{@model.get("value")}
        </blockquote>
      </div>
      """
    insertInDOM: (rowView)->
      rowView.rowContent.prepend(@$el)

    afterRender: ->
      @$el.find("blockquote").eq(0).editable
        placement: 'right'
        mode: 'popup'
        type: 'textarea'
        success: (uu, ent) =>
          @model.set("value", ent)

  VX.hint =
    html: ->
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      @$el.find("code").editable
        type: 'text',
        success: (uu, ent)=>
          @model.set("value", ent)

  VX.name =
    html: ->
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      @$el.find("code").editable
        type: 'text'
        success: (uu, ent)=>
          cleanName = XLF.sluggify ent
          @model.set("value", cleanName)

  VX.required =
    html: ->
      """<label><input type="checkbox"> Required?</label>"""
    afterRender: ->
      inp = @$el.find("input")
      inp.prop("checked", @model.get("value"))
      inp.change ()=> @model.set("value", inp.prop("checked"))

  VX
