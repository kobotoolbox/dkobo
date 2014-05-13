define 'cs!xlform/view.choices', [
        'backbone',
        'cs!xlform/model.choices',
        'cs!xlform/model.utils'
        'cs!xlform/view.pluggedIn.backboneView',
        'cs!xlform/view.templates',
        ], (
            Backbone,
            $choices,
            $modelUtils,
            $baseView,
            $viewTemplates,
            )->

  class ListView extends $baseView
    initialize: ({@rowView, @model})->
      @list = @model
      @row = @rowView.model
      $($.parseHTML $viewTemplates.row.selectQuestionExpansion()).insertAfter @rowView.$('.card__header')
      @$el = @rowView.$(".list-view")
      @ulClasses = @$("ul").prop("className")
    render: ->
      cardText = @rowView.$el.find('.card__text')
      if cardText.find('.card__buttons__multioptions.js-expand-multioptions').length is 0
        cardText.prepend $.parseHTML($viewTemplates.row.expandChoiceList())
      @$el.html (@ul = $("<ul>", class: @ulClasses))
      if @row.get("type").get("rowType").specifyChoice
        for option, i in @model.options.models
          new OptionView(model: option, cl: @model).render().$el.appendTo @ul
        while i < 2
          @addEmptyOption("Option #{++i}")

        @$el.removeClass("hidden")
      else
        @$el.addClass("hidden")
      @ul.sortable({
          axis: "y"
          cursor: "move"
          distance: 5
          items: "> li"
          placeholder: "option-placeholder"
          opacity: 0.9
          scroll: false
          deactivate: =>
            if @hasReordered
              @reordered()
            true
          change: => @hasReordered = true
        })
      btn = $($viewTemplates.$$render('xlfListView.addOptionButton'))
      btn.click ()=>
        i = @model.options.length
        @addEmptyOption("Option #{i+1}")

      @$el.append(btn)
      @
    addEmptyOption: (label)->
      emptyOpt = new $choices.Option(label: label)
      @model.options.add(emptyOpt)
      new OptionView(model: emptyOpt, cl: @model).render().$el.appendTo @ul

    reordered: (evt, ui)->
      ids = []
      @ul.find("> li").each (i,li)=>
        lid = $(li).data("optionId")
        if lid
          ids.push lid
      for id, n in ids
        @model.options.get(id).set("order", n, silent: true)
      @model.options.comparator = "order"
      @model.options.sort()
      @hasReordered = false

  class OptionView extends $baseView
    tagName: "li"
    className: "xlf-option-view well"
    events:
      "keyup input": "keyupinput"
    initialize: (@options)->
    render: ->
      @p = $("<span>")
      @c = $("<code> [<span>Automatic</span>]</code>")
      @d = $('<div>')
      if @model
        @p.html @model.get("label")
        @$el.attr("data-option-id", @model.cid)
        if @model.get('name') != $modelUtils.sluggify(@model.get('label'))
          $('span', @c).html @model.get("name")
          @model.set('setManually', true)
      else
        @model = new $choices.Option()
        @options.cl.options.add(@model)
        @p.html("Option #{1+@options.i}").addClass("preliminary")

      @p.on 'shown', (e, obj) -> obj.input.$input.on 'paste', (e) -> e.stopPropagation()
      @p.editable success: _.bind @saveValue, @
      @n = $('span', @c)
      @n.on 'shown', (e, obj) -> obj.input.$input.on 'paste', (e) -> e.stopPropagation()
      @n.editable success: (ev, val) =>
        other_names = @options.cl.getNames()
        if val is ''
          @model.unset('name')
          @model.set('setManually', false)
          val = 'Automatic'
          @$el.trigger("choice-list-update", @options.cl.cid)
        else
          val = $modelUtils.sluggify(val, {
                    preventDuplicates: other_names
                    lowerCase: false
                    lrstrip: true
                    incrementorPadding: false
                    characterLimit: 14
                    validXmlTag: false
                  })
          @model.set('name', val)
          @model.set('setManually', true)
          @$el.trigger("choice-list-update", @options.cl.cid)
        newValue: val
      @d.append(@p)
      @d.append(@c)
      @$el.html(@d)
      @
    keyupinput: (evt)->
      ifield = @$("input.inplace_field")
      if evt.keyCode is 8 and ifield.hasClass("empty")
        ifield.blur()

      if ifield.val() is ""
        ifield.addClass("empty")
      else
        ifield.removeClass("empty")
    saveValue: (ick, nval, oval, ctxt)->
      if nval is ""
        @$el.remove()
        @model.destroy()
      else
        @model.set("label", nval, silent: true)
        other_names = @options.cl.getNames()
        if !@model.get('setManually')
          @model.set("name", $modelUtils.sluggifyLabel(nval, other_names))
        @$el.trigger("choice-list-update", @options.cl.cid)
      ``

  ListView: ListView
  OptionView: OptionView
