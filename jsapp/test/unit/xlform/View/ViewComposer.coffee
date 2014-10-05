define ['cs!xlform/_view'], ($view) ->
  describe 'view composer', () ->
    class view_spy
      render: () -> @was_rendered = true
      attach_to: () -> @was_attached = true

    describe 'add method', () ->
      it 'adds a view to the end of the view array', () ->
        view_composer = new $view.utils.ViewComposer()
        view_composer.add 'new view'

        expect(view_composer.views.length).toBe 1
        expect(view_composer.views[0]).toBe 'new view'

      ###it 'hashes the view with the passed id', () ->
        view_composer = new view.utils.ViewComposer()
        view_composer.add 'new view', 'view id'

        expect(view_composer.views.length).toBe 1
        expect(view_composer.views[0]).toBe 'new view'
        expect(view_composer.views['view id']).toBe 'new view'

    describe 'remove method', () ->
      it 'removes the view at a given index when a number is passed', () ->
      it 'removes the view with the given id when a string is passed', () ->
      it 'removes the passed view', () ->
    describe 'get_view method', () ->
      it 'returns view at given index when number is passed', () ->
      it 'returns view with given id when string is passed', () ->
      it 'returns null when no view with given id exists', () ->###
    describe 'render method', () ->
      it 'renders all views', () ->
        view_composer = new $view.utils.ViewComposer()

        new_view1 = new view_spy()
        new_view2 = new view_spy()
        new_view3 = new view_spy()

        view_composer.add new_view1
        view_composer.add new_view2
        view_composer.add new_view3

        view_composer.render()

        expect(new_view1.was_rendered).toBeTruthy()
        expect(new_view2.was_rendered).toBeTruthy()
        expect(new_view3.was_rendered).toBeTruthy()

    describe 'attach_to method', () ->
      it 'attaches all views in order of addition', () ->
        view_composer = new $view.utils.ViewComposer()

        new_view1 = new view_spy()
        new_view2 = new view_spy()
        new_view3 = new view_spy()

        view_composer.add new_view1
        view_composer.add new_view2
        view_composer.add new_view3

        view_composer.attach_to('me')

        expect(new_view1.was_attached).toBeTruthy()
        expect(new_view2.was_attached).toBeTruthy()
        expect(new_view3.was_attached).toBeTruthy()

    ###describe 'bind event method', () ->
      it 'binds event to all views when no id provided', () ->
      it 'binds event to specific view when id provided', () ->
      it 'throws ItemNotFound error when no view matches passed id', () ->###
