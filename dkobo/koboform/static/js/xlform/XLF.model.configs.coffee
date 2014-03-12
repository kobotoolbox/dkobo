###
defaultSurveyDetails
--------------------
These values will be populated in the form builder and the user
will have the option to turn them on or off.

When exported, if the checkbox was selected, the "asJson" value
gets passed to the CSV builder and appended to the end of the
survey.

Details pulled from ODK documents / google docs. Notably this one:
  https://docs.google.com/spreadsheet/ccc?key=0AgpC5gsTSm_4dDRVOEprRkVuSFZUWTlvclJ6UFRvdFE#gid=0
###
XLF.defaultSurveyDetails =
  start_time:
    name: "start"
    label: "Start time"
    description: "Records when the survey was begun"
    default: true
    asJson:
      type: "start"
      name: "start"
  end_time:
    name: "end"
    label: "End time"
    description: "Records when the survey was marked as completed"
    default: true
    asJson:
      type: "end"
      name: "end"
  today:
    name: "today"
    label: "Today"
    description: "Includes todays date"
    default: false
    asJson:
      type: "today"
      name: "today"
  deviceid:
    name: "deviceid"
    label: "Device ID number"
    aliases: ["imei"]
    description: "Records the internal device ID number (works on Android phones)"
    default: false
    asJson:
      type: "deviceid"
      name: "deviceid"
  phoneNumber:
    name: "phonenumber"
    label: "Phone number"
    description: "Records the device's phone number, when available"
    default: false
    asJson:
      type: "phonenumber"
      name: "phonenumber"

do ->
  class SurveyDetailSchemaItem extends Backbone.Model
    _forSurvey: ()->
      name: @get("name")
      label: @get("label")
      description: @get("description")

  class XLF.SurveyDetailSchema extends Backbone.Collection
    model: SurveyDetailSchemaItem
    typeList: ()->
      unless @_typeList
        @_typeList = (item.get("name")  for item in @models)
      @_typeList

XLF.surveyDetailSchema = new XLF.SurveyDetailSchema(_.values(XLF.defaultSurveyDetails))

###
Default values for each type
###
XLF.defaultsForType =
  geopoint:
    label:
      value: "Record your current location"
  image:
    label:
      value: "Point and shoot! Use the camera to take a photo"
  video:
    label:
      value: "Use the camera to record a video"
  audio:
    label:
      value: "Use the camera's microphone to record a sound"
  note:
    label:
      value: "This note can be read out loud"
  integer:
    label:
      value: "Enter a number"
  barcode:
    hint:
      value: "Use the camera to scan a barcode"
  decimal:
    label:
      value: "Enter a number"
  date:
    label:
      value: "Enter a date"
  calculate:
    calculation:
      value: ""
  datetime:
    label:
      value: "Enter a date and time"

XLF.columns = ["type", "name", "label", "hint", "required", "relevant", "default", "constraint"]

XLF.lookupRowType = do->
  typeLabels = [
    ["note", "Note", preventRequired: true],
    ["text", "Text"], # expects text
    ["integer", "Integer"], #e.g. 42
    ["decimal", "Decimal"], #e.g. 3.14
    ["geopoint", "Geopoint (GPS)"], # Can use satelite GPS coordinates
    ["image", "Image", isMedia: true], # Can use phone camera, for example
    ["barcode", "Barcode"], # Can scan a barcode using the phone camera
    ["date", "Date"], #e.g. (4 July, 1776)
    ["datetime", "Date and Time"], #e.g. (2012-Jan-4 3:04PM)
    ["audio", "Audio", isMedia: true], # Can use phone microphone to record audio
    ["video", "Video", isMedia: true], # Can use phone camera to record video
    ["calculate", "Calculate"],
    ["select_one", "Select", orOtherOption: true, specifyChoice: true],
    ["select_multiple", "Multiple choice", orOtherOption: true, specifyChoice: true]
  ]

  class Type
    constructor: ([@name, @label, opts])->
      opts = {}  unless opts
      _.extend(@, opts)

  types = (new Type(arr) for arr in typeLabels)

  exp = (typeId)->
    for tp in types when tp.name is typeId
      output = tp
    output

  exp.typeSelectList = do ->
    () -> types

  exp

XLF.columnOrder = do ->
  (key)->
    if -1 is XLF.columns.indexOf key
      XLF.columns.push(key)
    XLF.columns.indexOf key

XLF.newRowDetails =
  name:
    value: ""
  label:
    value: "new question"
  type:
    value: "text"
  hint:
    value: ""
    _hideUnlessChanged: true
  required:
    value: false
    _hideUnlessChanged: true
  relevant:
    value: ""
    _hideUnlessChanged: true
  default:
    value: ""
    _hideUnlessChanged: true
  constraint:
    value: ""
    _hideUnlessChanged: true
