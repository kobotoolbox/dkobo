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
