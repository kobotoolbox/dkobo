XLF.iconDetails = [
  # row 1
    label: "Select one"
    faClass: "check-square-o"
    grouping: "r1"
    id: "select_one"
  ,
    label: "Select many"
    faClass: "list-alt"
    grouping: "r1"
    id: "select_multiple"
  ,
    label: "Text"
    faClass: "font"
    grouping: "r1"
    id: "text"
  ,
    label: "Integer"
    faClass: "sort-numeric-asc"
    grouping: "r1"
    id: "integer"
  ,

  # row 2
    label: "Decimal"
    faClass: "money"
    grouping: "r2"
    id: "decimal"
  ,
    label: "Date"
    faClass: "calendar-o"
    grouping: "r2"
    id: "date"
  ,
    label: "Time"
    faClass: "clock-o"
    grouping: "r2"
    id: "time"
  ,
    label: "Date + time"
    faClass: "calendar"
    grouping: "r2"
    id: "datetime"
  ,

  # r3
    label: "GPS Location"
    faClass: "map-marker"
    grouping: "r3"
    id: "geopoint"
  ,
    label: "Upload photo"
    faClass: "camera"
    grouping: "r3"
    id: "image"
  ,
    label: "Record audio"
    faClass: "microphone"
    grouping: "r3"
    id: "audio"
  ,
    label: "Record video"
    faClass: "video-camera"
    grouping: "r3"
    id: "video"
  ,

  # r4
    label: "Read a note"
    grouping: "r4"
    id: "note"
  ,
    label: "Scan barcode"
    faClass: "barcode"
    grouping: "r4"
    id: "barcode"
  ,
    label: "Acknowledge"
    faClass: "check-square-o"
    grouping: "r4"
    id: "acknowledge"
  ,
    label: "Calculate value"
    faClass: "superscript"
    grouping: "r4"
    id: "calculate"
  ,
  ]

class QtypeIcon extends Backbone.Model
  defaults:
    faClass: "question-circle"

class QtypeIconCollection extends Backbone.Collection
  model: QtypeIcon
  grouped: ()->
    unless @_groups
      @_groups = []
      grp_keys = []
      @each (model)=>
        grping = model.get("grouping")
        grp_keys.push(grping)  unless grping in grp_keys
        ii = grp_keys.indexOf(grping)
        @_groups[ii] or @_groups[ii] = []
        @_groups[ii].push model
    @_groups

XLF.icons = new QtypeIconCollection(XLF.iconDetails)