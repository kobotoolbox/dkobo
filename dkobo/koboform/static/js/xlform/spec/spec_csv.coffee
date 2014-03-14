describe "individual methods", ->
  ###
  tests individual methods including:
  csv.to(String|Object|Objects)
  csv.sheeted.to(String|Objects)
  ###
  it "doesnt cast strings to integers", ->
    newCsv = """
    col1,col2
    row1,234e567
    """
    csvObj = csv(newCsv)
    window.csvObj = csvObj
    expect(csvObj.toObjects()[0].col2).not.toBe(Infinity)
    expect(csvObj.toObjects()[0].col2).toBe("234e567")

  it "works with sheeted csvs", ->
    sheeted = csv.sheeted.toObjects(examples.sheetedCsv)
    expect(sheetName  for own sheetName of sheeted).toEqual ['survey', 'choices', 'settings']

describe "test which require csv.settings.parseFloat to be true", ->
  ###
  csv(...) and csv.sheeted(...) create js objects which can be converted
  or modified.
  ###
  beforeEach ->
    @csv_settings_parseFloat = csv.settings.parseFloat
    csv.settings.parseFloat = true
  afterEach ->
    csv.settings.parseFloat = @csv_settings_parseFloat

describe "Csv and SheetedCsv creators", ->
  ###
  csv(...) and csv.sheeted(...) create js objects which can be converted
  or modified.
  ###
  beforeEach ->
    @r = csv(examples.sparceCsv)

  it "collects accurate column and row details from string", ->
    cols = @r.columns
    rowArr = @r.rowArray
    expect(cols).toEqual ["a", "b", "c", "d"]
    expect(rowArr.length).toBe 4

  it "can add a row", ->
    @r.addRow a: 1, b: 2, c: 3, d: 4
    expect(@r.rowArray.length).toEqual 5

  it "can add a row with a new column", ->
    @r.addRow a: 1, b: 2, c: 3, d: 4, e: 5
    expect(@r.columns).toEqual ["a", "b", "c", "d", "e"]
    expect(@r.rowArray.length).toEqual 5

  it "can go fowards and backwards", ->
    checkEquality = (c1, c2)->
      expect(c1.columns.length).toBe(c2.columns.length)
      expect(c1.rows.length).toBe(c2.rows.length)
      c1j = JSON.stringify c1.rowArray
      c2j = JSON.stringify c2.rowArray
      expect(c1j).toEqual(c2j)

    checkEquality @r, csv(@r)
    checkEquality @r, csv(@r.toString())
    checkEquality @r, csv(@r.toObjects())

  it "does sheeted csvs right", ->
    d1 = csv.sheeted(examples.sheetedDifferent1)
    d2 = csv.sheeted(examples.sheetedDifferent2)
    reee = """
    "survey",,
    ,"label","type"
    ,"Name:","text"
    ,"Favorite color","select_one colors"
    ,"Favorite type of food","select_one foods"
    "choices",,
    ,"list","label"
    ,"colors","Black"
    ,"colors","White"
    ,"foods","Italian food"
    ,"foods","Mexican food"
    ,"foods","Chinese food"
    "settings",,
    ,"id","value"
    ,"setting1","TRUE"
    """
    expect(reee).toEqual(d1.toString())
    expect(reee).toEqual(d2.toString())

describe "Creating xlsform", ->
  it "works", ->
    sheeted = csv.sheeted()
    survey = csv()
    survey.addRow label: "Your name", type: "string", hint: "type your name"
    survey.addRow label: "Favorite color", type: "select_one colors"

    expect(survey.toString()).toEqual """
      "label","type","hint"
      "Your name","string","type your name"
      "Favorite color","select_one colors",
    """

    choices = csv()
    for color in "Red Yellow Pink Green Orange Purple Blue".split " "
      choices.addRow "list name": "colors", name: color.toLowerCase(), label: color

    sheeted.sheet "survey", survey
    sheeted.sheet "choices", choices

    expect(sheeted.toString()).toEqual """
      "survey",,,
      ,"label","type","hint"
      ,"Your name","string","type your name"
      ,"Favorite color","select_one colors",
      "choices",,,
      ,"list name","name","label"
      ,"colors","red","Red"
      ,"colors","yellow","Yellow"
      ,"colors","pink","Pink"
      ,"colors","green","Green"
      ,"colors","orange","Orange"
      ,"colors","purple","Purple"
      ,"colors","blue","Blue"
    """

describe "test escaped characters", ->
  beforeEach ->
    @sheet = csv()

  it "normal doc works", ->
    @sheet.addRow(name: "Aardvark", title: "Doctor")
    expect(@sheet.toString()).toEqual """
    "name","title"
    "Aardvark","Doctor"
    """
  it "has escaped characters export correctly", ->
    slash_text = "Has a back slash \\ here"
    @sheet.addRow(name: slash_text, title: "Doctor")
    expect(csv(@sheet.toString()).toObjects()[0].name).toEqual slash_text


  it "has quotes exported correctly", ->
    slash_text = 'This string has a quote " character'
    @sheet.addRow(name: slash_text, title: "Doctor")
    expect(csv(@sheet.toString()).toObjects()[0].name).toEqual slash_text

@examples = {}

examples.sequential = """
  a1,b1,c1,d1,e1,f1,g1,h1,i1,j1,k1,l1,m1,n1,o1,p1,q1,r1,s1,t1,u1,v1,w1,x1,y1,z1,aa1
  a2,b2,c2,d2,e2,f2,g2,h2,i2,j2,k2,l2,m2,n2,o2,p2,q2,r2,s2,t2,u2,v2,w2,x2,y2,z2,aa2
  a3,b3,c3,d3,e3,f3,g3,h3,i3,j3,k3,l3,m3,n3,o3,p3,q3,r3,s3,t3,u3,v3,w3,x3,y3,z3,aa3
  a4,b4,c4,d4,e4,f4,g4,h4,i4,j4,k4,l4,m4,n4,o4,p4,q4,r4,s4,t4,u4,v4,w4,x4,y4,z4,aa4
  a5,b5,c5,d5,e5,f5,g5,h5,i5,j5,k5,l5,m5,n5,o5,p5,q5,r5,s5,t5,u5,v5,w5,x5,y5,z5,aa5
  a6,b6,c6,d6,e6,f6,g6,h6,i6,j6,k6,l6,m6,n6,o6,p6,q6,r6,s6,t6,u6,v6,w6,x6,y6,z6,aa6
  a7,b7,c7,d7,e7,f7,g7,h7,i7,j7,k7,l7,m7,n7,o7,p7,q7,r7,s7,t7,u7,v7,w7,x7,y7,z7,aa7
  a8,b8,c8,d8,e8,f8,g8,h8,i8,j8,k8,l8,m8,n8,o8,p8,q8,r8,s8,t8,u8,v8,w8,x8,y8,z8,aa8
  a9,b9,c9,d9,e9,f9,g9,h9,i9,j9,k9,l9,m9,n9,o9,p9,q9,r9,s9,t9,u9,v9,w9,x9,y9,z9,aa9
  a10,b10,c10,d10,e10,f10,g10,h10,i10,j10,k10,l10,m10,n10,o10,p10,q10,r10,s10,t10,u10,v10,w10,x10,y10,z10,aa10
  a11,b11,c11,d11,e11,f11,g11,h11,i11,j11,k11,l11,m11,n11,o11,p11,q11,r11,s11,t11,u11,v11,w11,x11,y11,z11,aa11
"""

examples.sparceCsv = """
  a,b,c,d
  1,,,
  1,2,,
  3,4,5,
  5,,,33
"""

examples.sheetedCsv = """
  survey
  ,label,type
  ,Name:,text
  ,"Favorite color","select_one colors"
  choices,,
  ,list,label
  ,colors,Black
  ,colors,White
  settings,col1,col2
  ,setting1,true
  ,setting2,false
"""

examples.sheetedDifferent1 = """
  survey,label,type
  choices,list,label
  ,,
  ,,
  survey,Name:,text
  ,,
  survey,"Favorite color","select_one colors"
  choices,colors,Black
  ,colors,White
  ,,
  ,,
  survey,"Favorite type of food","select_one foods"
  choices,foods,"Italian food"
  ,foods,"Mexican food"
  ,foods,"Chinese food"
  ,,
  ,,
  settings,,
  ,id,value
  ,setting1,TRUE
"""

examples.sheetedDifferent2 = """
  survey,label,type
  ,Name:,text
  ,"Favorite color","select_one colors"
  ,"Favorite type of food","select_one foods"
  choices,,
  ,list,label
  ,colors,Black
  ,colors,White
  ,foods,"Italian food"
  ,foods,"Mexican food"
  ,foods,"Chinese food"
  settings,,
  ,id,value
  ,setting1,TRUE
"""
