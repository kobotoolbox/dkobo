XLF.iconDetails = [
    label: "Upload photo"
    faClass: "camera"
    grouping: "media"
    id: "image"
  ,
    label: "Record audio"
    faClass: "microphone"
    grouping: "media"
    id: "audio"
  ,
    label: "Record video"
    faClass: "video-camera"
    grouping: "media"
    id: "video"
  ,
    label: "Scan barcode"
    faClass: "barcode"
    grouping: "media"
    id: "barcode"
  ,
    label: "Text"
    faClass: "font"
    grouping: "text"
    id: "text"
  ,
    label: "Integer"
    faClass: "sort-numeric-asc"
    grouping: "text"
    id: "integer"
  ,
    label: "Decimal"
    faClass: "money"
    grouping: "text"
    id: "decimal"
  ,
    label: "Read a note"
    grouping: "text"
    id: "note"
  ,
    label: "Acknowledge"
    faClass: "check-square-o"
    grouping: "text"
    id: "acknowledge"
  ,
    label: "Select one"
    faClass: "check-square-o"
    grouping: "choice"
    id: "select_one"
  ,
    label: "Select many"
    faClass: "list-alt"
    grouping: "choice"
    id: "select_multiple"
  ,
    label: "Date"
    faClass: "calendar-o"
    grouping: "choice"
    id: "date"
  ,
    label: "Date + time"
    faClass: "calendar"
    grouping: "choice"
    id: "datetime"
  ,
    label: "Time"
    faClass: "clock-o"
    grouping: "choice"
    id: "time"
  ,
    label: "GPS Location"
    faClass: "map-marker"
    grouping: "misc"
    id: "geopoint"
  ,
    label: "Calculate value"
    faClass: "superscript"
    grouping: "misc"
    id: "calculate"
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