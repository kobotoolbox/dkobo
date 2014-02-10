aliases_dict =
  group: [
      # standard group items
      "group"
      "begin group"
      "end group"
      "begin_group"
      "end_group"
      # include repeat with group, for now
      "begin repeat"
      "end repeat"
      "begin_repeat"
      "end_repeat"
    ]

aliases = (name)-> aliases_dict[name] || [name]

XLF.aliases = aliases