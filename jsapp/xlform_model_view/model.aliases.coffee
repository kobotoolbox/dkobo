define 'cs!xlform/model.aliases', ['underscore'], (_)->
  aliases_dict =
    group: [
        "group"
        "begin group"
        "end group"
        "begin_group"
        "end_group"
      ],
    repeat: [
        "repeat"
        "begin repeat"
        "end repeat"
        "begin_repeat"
        "end_repeat"
      ]

  aliases = (name)-> aliases_dict[name] or [name]

  q = {}
  q.groupsOrRepeats = ()->
    _.flatten [aliases('group'), aliases('repeat')]

  q.requiredSheetNameList = ()->
    ['survey']

  q.testGroupOrRepeat = (type)->
    # Returns an object if type is group or repeat (begin or end)
    #  otherwise, returns false
    out = false
    if type in aliases_dict.group
      out = {type: 'group'}
    else if type in aliases_dict.repeat
      out = {type: 'repeat'}
    if out and out.type
      out.begin = !type.match(/end/)
    out

  q.hiddenTypes = ()->
    _.flatten [
      ['imei', 'deviceid'],
      ['start'],
      ['end'],
      ['today'],
      ['simserial'],
      ['subscriberid'],
      ['phonenumber'],
    ]

  aliases.custom = q

  aliases.q = aliases.custom
  aliases