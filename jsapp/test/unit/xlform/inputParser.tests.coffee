define [
        'cs!xlform/model.inputParser',
        'cs!xlform/model.choices',
        'cs!test/fixtures/surveys',
        ], (
            $inputParser,
            $choices,
            $surveys,
            )->

  describe '" $inputParser', ->
    describe '. languages "', ->
      describe 'has working columnParsers', ->
        ###
        This tests the internal parsers' ability to verify the correct
        number of colon-separated arguments and responses

        see model.inputParser's ParseSorter class and sorter methods
        for more info.
        ###
        beforeEach ->
          _parsers = $inputParser.languages.__parsers
          @parseSimple =  (c)-> _parsers.simple(c)
          @parseRegular = (c)-> _parsers.regular(c)
          @parseMedia =   (c)-> _parsers.media(c)

        describe 'and parses simple columns', ->
          it 'returns the correct value', ->
            expect(@parseSimple('columnName')).toEqual(column: 'columnName')

          it 'fails multiple values are provided', ->
            # 1 value ok. 2 or 3 values, not ok.
            expect((=> @parseSimple('a1'))).not.toThrow()
            expect((=> @parseSimple('a1::a2'))).toThrow()
            expect((=> @parseSimple('a1::a2::a3'))).toThrow()

        describe 'and parses regular columns', ->
          it 'with one value', ->
            expect(@parseRegular('columnName')).toEqual(column: 'columnName', language: '')
          it 'with two values', ->
            expect(@parseRegular('columnName::lang')).toEqual(column: 'columnName', language: 'lang')
          it 'fails when three values are passed', ->
            # 1 or 2 values ok. 3 values, not ok.
            expect((=> @parseRegular('a1'))).not.toThrow()
            expect((=> @parseRegular('a1::a2'))).not.toThrow()
            expect((=> @parseRegular('a1::a2::a3'))).toThrow()

        describe 'and parses media columns', ->
          it 'with two values', ->
            expect(@parseMedia('columnName::mtype')).toEqual(column: 'columnName', mediaType: 'mtype', language: '')
          it 'with three values', ->
            expect(@parseMedia('columnName::mtype::lang')).toEqual(column: 'columnName', mediaType: 'mtype', language: 'lang')
          it 'fails with 1 or 4 values', ->
            # 2 or 3 values ok. 1 or 4 values not ok.
            expect((=> @parseMedia('a1'))).toThrow()
            expect((=> @parseMedia('a1::a2'))).not.toThrow()
            expect((=> @parseMedia('a1::a2::a3'))).not.toThrow()
            expect((=> @parseMedia('a1::a2::a3::a4'))).toThrow()

      describe 'has a working parse-sorter', ->
        beforeEach ->
          @sorter = $inputParser.languages.__createParseSorter({
              simple:
                ['name', 'constraint', 'appearance']
              media:
                [/^media::.+/, /misc_regex.*/]
              fallback:
                'regular'
            })

        describe 'gives the right column parser', ->
          beforeEach ->
            @expectColumnParserId = (colName)=>
              expect(@sorter._get_handler(colName).fnId)
          it 'exact string lookup', ->
            @expectColumnParserId('name').toBe('simple')
            @expectColumnParserId('constraint').toBe('simple')
            @expectColumnParserId('appearance').toBe('simple')
          it 'regex lookup', ->
            @expectColumnParserId('media::blahblah').toBe('media')
            @expectColumnParserId('misc_regexblahblah').toBe('media')
          it 'falls back on default', ->
            @expectColumnParserId('unknowncolumn').toBe('regular')

      describe 'uses the parseSorter and the columnParsers together', ->
        beforeEach ->
          @listLanguages = (s, psOpts)->
            uniqLangs = []
            if !psOpts
              throw new Error("provide psOpts to go to the ParseSorter")
            sorter = $inputParser.languages.__createParseSorter(psOpts)
            for own sId, sht of s
              for row in sht
                for own col, val of row
                  sorter._import_column(col)
              for ll in sorter.langs() when ll not in uniqLangs
                uniqLangs.push(ll)
            uniqLangs.sort()
            uniqLangs

        describe 'interprets parse sort opts properly', ->
          it 'fails if no fallback is set', ->
            inp = JSON.parse("""
                {
                  "survey": [
                    {
                      "invalidkey": "val2"
                    }
                  ]
                }
              """)
            expect((=> @listLanguages(inp, fallback: false))).toThrow()
            expect((=> @listLanguages(inp, fallback: 'simple'))).not.toThrow()

        it 'lists the languages in the document', ->
          inp = JSON.parse("""
              {
                "survey": [
                  {
                    "key1": "val1",
                    "key2::lang1": "val2"
                  }
                ],
                "choices": [
                  {
                    "k4::lang2": "v4",
                    "k5": "v5"
                  }
                ]
              }
            """)
          expect(@listLanguages(inp, fallback: "regular")).toEqual(["", "lang1", "lang2"])

        it 'lists all languages in a complex xlsform document', ->
          inp = JSON.parse("""
              {
                "survey": [
                  {
                    "type": "text",
                    "name": "myname",
                    "label::english": "label en",
                    "media::x::french": "media fr"
                  }
                ],
                "choices": [
                  {
                    "list_name": "yn",
                    "name": "yes",
                    "label::dutch": "Ja"
                  },
                  {
                    "list_name": "yn",
                    "name": "no",
                    "label::german": "Nien"
                  }
                ]
              }
            """)

          # using options similar to what will be used on parsing xlsforms
          langs = @listLanguages inp, {
            simple: ['list_name', 'type', 'name', 'constraint', 'appearance']
            media: [/^media::.+/]
            fallback: 'regular'
          }

          expect(langs).toEqual(["dutch", "english", "french", "german"])

    describe '. parse()"', ->
      it 'parses group hierarchy', ->
        results = $inputParser.parseArr('survey', [
            {type: 'begin group', name: 'grp1'},
            {type: 'text', name: 'q1'},
            {type: 'end group'},
          ])
        expect(results).toEqual([
            {
              type: 'group',
              name: 'grp1',
              __rows: [{type: 'text', name: 'q1'}]
            }
          ])
      it 'parses nested groups hierarchy', ->
        results = $inputParser.parseArr('survey', [
            {type: 'begin group', name: 'grp1'},
            {type: 'begin group', name: 'grp2'},
            {type: 'text', name: 'q1'},
            {type: 'text', name: 'q2'},
            {type: 'end group'},
            {type: 'end group'},
          ])
        expect(results).toEqual([ { type : 'group', name : 'grp1', __rows : [ { type : 'group', name : 'grp2', __rows : [ { type : 'text', name : 'q1' }, { type : 'text', name : 'q2' } ] } ] } ])
      it 'parses non-grouped list of questions', ->
        results = $inputParser.parseArr('survey', [
            {type: 'text', name: 'q1'},
            {type: 'text', name: 'q2'},
          ])
        expect(results).toEqual([ { type : 'text', name : 'q1' }, { type : 'text', name : 'q2' } ])

