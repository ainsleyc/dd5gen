fs = require 'fs'
expect = require('chai').expect

AssetUtils = require '../lib/asset-utils'

characterData = JSON.parse(fs.readFileSync('./public/assets/character.json', 'utf-8'))
listsData = JSON.parse(fs.readFileSync('./public/assets/lists.json', 'utf-8'))

collectField = (struct, op, results) ->
  for category, categoryBlock of struct
    for field, block of categoryBlock
      if block[op]?
        results.push({ field: field, params: block[op] })
      else
        for subField, subBlock of block
          if subBlock[op]?
            results.push({
              field: field,
              subField: subField,
              params: block[subField]
            })

describe 'assets validation', ->

  describe 'lists', ->
    it 'should contain standard format', ->
      for key, block of listsData
        for option in block.values
          expect(option.id).to.exist

  describe '$adjust', ->
    it 'should only be applied to existing fields', ->
      matches = []
      collectField(characterData, '$adjust', matches)
      for match in matches
        expect(AssetUtils.getPath(characterData.base, match.field)).to.exist

    it 'should only use legal modifiers', ->
      # TBD move to consts file?
      modifiers = {
        const: true
        perLevel: true
        obj: true
      }
      matches = []
      collectField(characterData, '$adjust', matches)
      for match in matches
        expect(typeof match.params).to.equal('object')
        for mod, value of match.params
          expect(modifiers[mod]).to.exist
          expect(typeof value).to.equal('number')

  describe '$add', ->

    whitelist =
      'per_level': true

    it 'should only be applied to existing fields', ->
      matches = []
      collectField(characterData, '$add', matches)
      for match in matches
        expect(characterData.base[match.field]).to.exist

    it 'should only add existing fields', ->
      matches = []
      collectField(characterData, '$add', matches)
      for match in matches
        if not whitelist[match.field]
          expect(listsData[match.field]).to.exist
        for option in match.params
          if option.id?
            expect(
              listsData[match.field].values[option.id] or
              listsData[match.field].groups[option.id]
            ).to.exist

    it 'should accept sub $select field', ->
      matches = []
      collectField(characterData, '$add', matches)
      for match in matches
        if not whitelist[match.field]
          expect(listsData[match.field]).to.exist
        for option in match.params
          if option.$select?
            expect(
              listsData[option.$select] or
              listsData[match.field].groups[option.$select]
            ).to.exist

    it 'should accept sub $select-subset field', ->
      matches = []
      collectField(characterData, '$add', matches)
      for match in matches
        if not whitelist[match.field]
          expect(listsData[match.field]).to.exist
        for option in match.params
          if option['$select-subset']?
            expect(option['$select-subset'] instanceof Array).to.be.true
            for subOption in option['$select-subset']
              expect(listsData[match.field].values[subOption.id]).to.exist

  describe '$select', ->
    it 'should have matching list for each $select', ->
      matches = []
      collectField(characterData, '$select', matches)
      for match in matches
        expect(listsData[match.field]).to.exist

  describe '$select-subset', ->
    it 'should have matching options to main list', ->
      matches = []
      collectField(characterData, '$select-subset', matches)
      for match in matches
        expect(listsData[match.field]).to.exist
        for param in match.params
          expect(listsData[match.field].values[param.id]).to.exist

  describe '$select-custom', ->
    it 'should contain a custom picklist', ->
      matches = []
      collectField(characterData, '$select-custom', matches)
      for match in matches
        for param in match.params
          expect(param.id).to.exist

  describe '$choose', ->
    it 'should have matching list for each $choose', ->
      matches = []
      collectField(characterData, '$choose', matches)
      for match in matches
        expect(listsData[match.params]).to.exist

    it 'should have a matching character opton for each $choose option', ->
      matches = []
      collectField(characterData, '$choose', matches)
      for match in matches
        for key, block of listsData[match.params].values
          expect(characterData[key]).to.exist




