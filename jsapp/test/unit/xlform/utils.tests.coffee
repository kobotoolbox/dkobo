define [
        'cs!xlform/model.utils',
        'cs!xlform/model.utils.markdownTable',
        ], (
            $utils,
            $markdownTable,
            )->

  describe 'model.utils', ->
    describe 'sluggify', ->
      it 'lowerCases: true', ->
        expect($utils.sluggify("TESTING LOWERCASE TRUE", lowerCase: true)).toEqual('testing_lowercase_true')
      it 'lowerCases: false', ->
        expect($utils.sluggify("TESTING LOWERCASE FALSE", lowerCase: false)).toEqual('TESTING_LOWERCASE_FALSE')

  describe 'model.utils.markdownTable', ->
    it 'converts to and from a simple markdown representation of a survey', ->
      ###
      # str should equal this table:
      | survey   |    |      |      |
      |          | c0 | c1   | c2   |
      |          | r1 | r1v1 | r1v2 |
      |          | r2 | r2v1 | r2v2 |
      |          | r3 | r3v1 | r3v2 |
      | settings |    |      |      |
      |          | c0 | c1   | c2   |
      |          | r1 | r1v1 | r1v2 |
      |          | r2 | r2v1 | r2v2 |
      |          | r3 | r3v1 | r3v2 |
      ###
      str = $markdownTable.csvJsonToMarkdown({
          survey:
            columns: ['c0', 'c1', 'c2'],
            rows: [
              ['r1', 'r1v1', 'r1v2']
              ['r2', 'r2v1', 'r2v2']
              ['r3', 'r3v1', 'r3v2']
            ]
          settings:
            columns: ['c0', 'c1', 'c2'],
            rows: [
              ['r1', 'r1v1', 'r1v2']
              ['r2', 'r2v1', 'r2v2']
              ['r3', 'r3v1', 'r3v2']
            ]
        })
      expect(str.split('\n').length).toBe(10)

      _r = $markdownTable.mdSurveyStructureToObject(str)
      expect(_r).toEqual({
        survey: [
            { c0: "r1", c1: "r1v1", c2: "r1v2" },
            { c0: "r2", c1: "r2v1", c2: "r2v2" },
            { c0: "r3", c1: "r3v1", c2: "r3v2" },
          ],
        settings: [
            { c0: "r1", c1: "r1v1", c2: "r1v2" },
            { c0: "r2", c1: "r2v1", c2: "r2v2" },
            { c0: "r3", c1: "r3v1", c2: "r3v2" },
          ]
      })
