define 'cs!xlform/view.utils', ['xlform/view.utils.validator'], (Validator)->
  viewUtils = {}
  viewUtils.Validator = Validator

  viewUtils.makeEditable = (that, model, selector, {property, transformFunction, options, edit_callback}) ->
    if !transformFunction?
      transformFunction = (value) -> value
    if !property?
      property = 'value'

    if !edit_callback?
      edit_callback = _.bind (ent) ->
          ent = transformFunction ent
          ent = ent.replace(/\t/g, '')
          model.set(property, ent, validate: true)
          if(model.validationError && model.validationError[property])
            return model.validationError[property]

          newValue: ent
        , that

    if !(selector instanceof jQuery)
      selector =that.$el.find(selector)

    selector.on 'shown', (e, obj) -> obj.input.$input.on 'paste', (e) -> e.stopPropagation()


    enable_edit = () ->
      parent_element = selector.parent()
      parent_element.find('.error-message').remove()
      current_value = selector.text()

      edit_box = $('<input />', type:'text', value:current_value, class:'js-cancel-sort js-blur-on-select-row')
      selector.replaceWith edit_box
      edit_box.focus()

      commit_edit = () ->
        parent_element.find('.error-message').remove()
        if options? && options.validate? && options.validate(edit_box.val())?
          new_value = options.validate(edit_box.val())
        else
          new_value = edit_callback edit_box.val()

        if !new_value?
          new_value = newValue: edit_box.val()

        if new_value.newValue?
          edit_box.replaceWith(selector)
          selector.text new_value.newValue
          selector.click enable_edit
        else
          error_box = $('<div class="error-message">' + new_value + '</div>')
          parent_element.append(error_box)

      edit_box.blur commit_edit
      edit_box.keypress (event) ->
        if event.which == 13
          commit_edit event


    selector.click enable_edit
    #selector.editable editableOpts


  viewUtils.reorderElemsByData = (selector, parent, dataAttribute)->
    arr = []
    parentEl = false
    $(parent).find(selector).each (i)->
      if i is 0
        parentEl = @parentElement
      else if @parentElement isnt parentEl
        throw new Error("All reordered items must be siblings")

      $el = $(@).detach()
      val = $el.data(dataAttribute)
      arr[val] = $el  if _.isNumber(val)
    $el.appendTo(parentEl)  for $el in arr when $el
    return

  viewUtils.cleanStringify = (atts)->
    attArr = []
    for key, val of atts when val isnt ""
      attArr.push """<span class="atts"><i>#{key}</i>="<em>#{val}</em>"</span>"""
    attArr.join("&nbsp;")

  viewUtils.debugFrame = do ->
    $div = false
    debugFrameStyle =
      position: "fixed"
      width: "95%"
      height: "50%"
      bottom: 10
      left: "2.5%"
      overflow: "auto"

    showFn = (txt)->
      html = txt.split("\n").join("<br>")
      $div = $("<div>", class: "well debug-frame").html("<code>#{html}</code>")
        .css(debugFrameStyle)
        .appendTo("body")
    showFn.close = ->
      if $div
        $div.remove()
        $div = false
    showFn

  viewUtils.launchQuestionLibrary = do ->
    launch = (opts={})->
      wrap = $("<div>", class: "js-click-remove-iframe iframe-bg-shade")
      $("<div>").text("""
        Launch question library in this element
        <section koboform-question-library=""></section>
      """).appendTo(wrap)
      wrap.click ()-> wrap.remove()
      wrap

    launch

  viewUtils.enketoIframe = do ->
    enketoServer = "https://enketo.org"
    enketoPreviewUri = "/webform/preview"
    buildUrl = (previewUrl)->
      """#{enketoServer}#{enketoPreviewUri}?form=#{previewUrl}"""

    _loadConfigs = (options)->
      if options.enketoPreviewUri
        enketoPreviewUri = options.enketoPreviewUri
      if options.enketoServer
        enketoServer = options.enketoServer

    clickCloserBackground = ->
      $("<div>", class: "js-click-remove-iframe")

    launch = (previewUrl, options={})->
      _loadConfigs(options)
      wrap = $("<div>", class: "js-click-remove-iframe iframe-bg-shade")
      $("<iframe>", src: buildUrl(previewUrl)).appendTo(wrap)
      wrap.click ()-> wrap.remove()
      wrap

    launch.close = ()->
      $(".iframe-bg-shade").remove()

    launch.fromCsv = (surveyCsv, options={})->
      previewServer = options.previewServer or ""
      data = JSON.stringify(body: surveyCsv)
      loadConfigs(options)
      onError = options.onError or (args...)-> console?.error.apply(console, args)
      $.ajax
        url: "#{previewServer}/koboform/survey_preview/"
        method: "POST"
        data: data
        complete: (jqhr, status)=>
          response = jqhr.responseJSON
          if status is "success" and response and response.unique_string
            unique_string = response.unique_string
            launch("#{previewServer}/koboform/survey_preview/#{unique_string}").appendTo("body")
            options.onSuccess()  if options.onSuccess?
          else if status isnt "success"
            onError "Error launching preview: ", status, jqhr
          else if response and response.error
            onError response.error
          else
            onError "SurveyPreview response JSON is not recognized"

    launch

  viewUtils