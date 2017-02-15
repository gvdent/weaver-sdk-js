require("./test-suite")

describe 'WeaverModel', ->

  it 'should build a simple model', ->

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    })
    assert.equal(rockModel.attributes.definition, '{"origin":"@hasOrigin","age":"hasAge"}')


  it 'should save a simple model', (done)->

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    }).save().then(->

      rockModelId = rockModel.id()
      rockModel = null

      Weaver.Node.load(rockModelId).then((rockMod)->
        assert.equal(rockMod.attributes.definition, '{"origin":"@hasOrigin","age":"hasAge"}')
        done()
      )
    )
    return

  it 'should build a model with a static attribute', (done)->

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    })
    .setStatic("age", "Really damn old.")

    Rock = rockModel.buildClass()
    mrRock = new Rock()
    mrRock.get("age").then((res)->
      assert.equal(res, "Really damn old.")
      mrRock.save()
      done()
    )
    return

  it 'should save a model with a static attribute', (done)->

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    })
    .setStatic("age", "Really damn old.")
    .save().then(->

      rockModelId = rockModel.id()
      rockModel = null

      Weaver.Node.load(rockModelId).then((node)->

#      console.log(rockMod) # supplying a constructor to Weaver.Node.load() seems to be failing
        rockMod = new Weaver.Model(node.id())
        rockMod._loadFromQuery(node)
        Rock = rockMod.buildClass()
        mrRock = new Rock()
        mrRock.get("age").then((res)->
          assert.equal(res, "Really damn old.")
          done()
        )
      )
    )
    return

  it 'should build a model with a static relation', (done)->

    canada = new Weaver.Node('Canada')
    canada.save()

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    })
    .setStatic("origin", canada)

    Rock = rockModel.buildClass()
    mrRock = new Rock()
    mrRock.save()
    mrRock.get("origin").then((res)->
      assert.equal(res[0].id(), 'Canada')
      done()
    )
    return

  it 'should save a model with a static relation', (done)->

    canada = new Weaver.Node('Canada')
    canada.save()

    rockModel = new Weaver.Model("RockModel")
    rockModel.structure({
      origin: "@hasOrigin"
      age: "hasAge"
    })
    .setStatic("origin", canada)
    .save().then(->

      rockModelId = rockModel.id()
      rockModel = null

      Weaver.Node.load(rockModelId).then((node)->

        rockMod = new Weaver.Model(node.id())
        rockMod._loadFromQuery(node)

        Rock = rockMod.buildClass()
        mrRock = new Rock()
        mrRock.get("origin").then((res)->
          assert.equal(res[0].id(), 'Canada')
          done()
        )
      )
    )
    return

  it 'should support deep "get" calls', (done)->

    countryType = new Weaver.Node('Country')
    countryType.save().then(->
      countryModel = new Weaver.Model("CountryModel")
      countryModel.structure({
        type: "@hasType"
        name: "hasLabel"
      })
      .setStatic("type", countryType)
      .save().then(->

        Country = countryModel.buildClass()
        canada = new Country("Canada")
        canada.setProp('name', 'Canada')
        canada.save().then(->

          ireland = new Country("Ireland")
          ireland.setProp('name', 'Ireland')
          ireland.save().then(->

            rockModel = new Weaver.Model("RockModel")
            rockModel.structure({
              origin: ["@hasOrigin", countryModel.id()]
              age: "hasAge"
              originName: "origin.name"
            })
            .setStatic("origin", canada)
            .setStatic("origin", ireland)
            .save().then(->

              canada = null
              countryModel = null

              Rock = rockModel.buildClass()
              mrRock = new Rock('Rock')
              mrRock.save().then(->
                mrRock.get("origin.name").then((res)->
                  assert.notEqual(res.indexOf('Canada'), -1)
                  assert.notEqual(res.indexOf('Ireland'), -1)
                  assert.equal(res.indexOf('Netherlands'), -1)
                  mrRock.get("origin.type").then((res)->
                    assert.equal(res[0].id(), 'Country')
                    assert.equal(res[1].id(), 'Country')
                    mrRock.get('originName').then((res)->
                      assert.notEqual(res.indexOf('Canada'), -1)
                      assert.notEqual(res.indexOf('Ireland'), -1)
                      assert.equal(res.indexOf('Netherlands'), -1)
                      done()
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
    return

  it 'should support deep "get" calls (3 levels + db loaded model)', (done)->
    quarryModel = new Weaver.Model("QuarryModel")
    quarryModel.structure({
      contains: ["@hasRock", 'RockModel']
      originName: "contains.origin.name"
    })
    .setStatic('contains', new Weaver.Node('Rock'))
    .save().then(->
      Quarry = quarryModel.buildClass()
      myQuarry = new Quarry()

      myQuarry.get('contains.origin.type').then((res)->
        assert.equal(res[0].id(), 'Country')
        myQuarry.get('originName').then((res)->
          assert.include(res, 'Ireland')
          assert.include(res, 'Canada')
          done()
        )
      )
    )
    return
