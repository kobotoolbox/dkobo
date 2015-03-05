define [
        'cs!xlform/csv',
        ], (
            csv,
            )->


  example2 = "\"regex_sheet\"\r\n\"\",\"col1\",\"regexcol\"\r\n\"\",\"row1\",\"regex( \\s+ )\"\r\n\"regex_sheet2\"\r\n\"\",\"s2col1\",\"example2\"\r\n\"\",\"s2row1\",\"\\s\\d\\w\\S\\D\\W\"\r\n"

  silly_cell = """
    regex(., '^\\S+( \\S+){4}$' )
  """
  example = """
    "type","constraint"
    "text","#{silly_cell}"
    """

  describe "csv parsing", ->
    beforeEach ->
      window._csv = csv
      @compile = (content)->
        csv(content).toObjects()[0]
    it "equals", ->
      parse_content_body = ->
        csv(example2)
      expect(parse_content_body).not.toThrow()
    it "handles simple csvs", ->
      ex1 = @compile("""
        a,b,c,d
        e,f,g,h
        """)
      expect(ex1.a).toBe('e')
      expect(ex1.b).toBe('f')
      expect(ex1.c).toBe('g')
      expect(ex1.d).toBe('h')

    it "handles csvs with quotes", ->
      ex1 = @compile("""
        "a","b","c","d"
        "e","f","g","h"
        """)
      expect(ex1.a).toBe('e')
      expect(ex1.b).toBe('f')
      expect(ex1.c).toBe('g')
      expect(ex1.d).toBe('h')

    it "imports cells with escape characters", ->
      ex1 = @compile(example)
      expect(ex1.type).toBe('text')
      expect(ex1.constraint).toBe(silly_cell)

    it "reexports cells with escape characters", ->
      converted_to_objects = csv(example).toObjects()
      converted_to_string = csv(converted_to_objects).toString()
      expect(converted_to_string).toEqual(example)
