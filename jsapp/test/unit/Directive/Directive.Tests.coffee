directive_tests = ->
  beforeEach test_helper.initialize_angular_modules

  describe "Top level menu Directive", top_level_menu_directive_tests

  describe "InfoList Directive", info_list_directive_tests
  describe "ItemList Directive", item_list_directive_tests