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
        <blockquote>
          #{@model.get("value")}
        </blockquote>
      </div>
      """
    insertInDOM: (rowView)->
      rowView.rowContent.prepend(@$el)

    afterRender: ->
      @$el.find("blockquote").eq(0).editInPlace
        save_if_nothing_changed: true
        field_type: "textarea"
        textarea_cols: 50
        textarea_rows: 3
        callback: (uu, ent)=>
          @model.set("value", ent)
          if ent is "" then "..." else ent

  VX.hint =
    html: ->
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      @$el.find("code").editInPlace
        save_if_nothing_changed: true
        callback: (uu, ent)=>
          @model.set("value", ent)
          if ent is "" then "..." else ent

  VX.name =
    html: ->
      """
      #{@model.key}: <code>#{@model.get("value")}</code>
      """
    afterRender: ->
      @$el.find("code").editInPlace
        save_if_nothing_changed: true
        callback: (uu, ent)=>
          cleanName = XLF.sluggify ent
          @model.set("value", cleanName)
          if ent is "" then "..." else cleanName

  VX.required =
    html: ->
      """<label><input type="checkbox"> Required?</label>"""
    afterRender: ->
      inp = @$el.find("input")
      inp.prop("checked", @model.get("value"))
      inp.change ()=> @model.set("value", inp.prop("checked"))

  VX
