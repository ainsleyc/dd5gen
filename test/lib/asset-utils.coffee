fs = require 'fs'
expect = require('chai').expect
AssetUtils = require '../../lib/asset-utils'

describe 'AssetUtils', ->

  listsData = JSON.parse(fs.readFileSync('./public/assets/lists.json', 'utf-8'))
  characterData = null
  base = null
  beforeEach(->
    characterData = JSON.parse(fs.readFileSync('./public/assets/character.json', 'utf-8'))
    base = characterData.base
  )

  describe 'getPath', ->

    it 'should get correct path from an object 1', ->
      path = "attr.con"
      result = AssetUtils.getPath(base, path)
      expect(result.value).to.equal(0)

    it 'should get correct path from an object 2', ->
      path = "prof_armor.$add"
      result = AssetUtils.getPath(characterData.bard, path)
      expect(result[0].id).to.equal("light armor")

  describe '$set', ->

    it 'should set correctly', ->
      orig = {}
      merge = [
        { val: "test7" }
      ]
      result = AssetUtils._$set(orig, merge)
      expect(result).to.equal(merge)

  describe '$adjust', ->

    it 'should adjust correctly', ->
      orig = base.attr.cha
      merge = {
        const: 1
      }
      result = AssetUtils._$adjust(orig, merge)
      expect(result.value).to.equal(1)

  describe '$add', ->

    it 'should get correctly append to original', ->
      orig = base.language
      merge = [
        { val: "test7" }
        { val: "test8" }
      ]
      result = AssetUtils._$add(orig, merge)
      expect(result.length).to.equal(2)

    it 'should fail if orig isnt Array', ->
      orig = {}
      merge = []
      try
        result = AssetUtils._$add(orig, merge)
      catch e
        return
      throw new Error

    it 'should fail if merge isnt Array', ->
      orig = []
      merge = {}
      try
        result = AssetUtils._$add(orig, merge)
      catch e
        return
      throw new Error

  describe 'apply', ->

    it 'should correctly join race', ->
      AssetUtils.apply(base, characterData.dwarf)
      expect(base.size.value).to.equal('medium')
      expect(base.attr.con.value).to.equal(2)
      expect(base.prof_weapon.length).to.equal(4)

    it 'should correctly join class', ->
      AssetUtils.apply(base, characterData.bard)
      expect(base.hp.perm.value).to.equal(8)
      expect(base.levels.bard).to.equal(1)
      expect(base.spells_bard).to.exist

    it 'should correctly join multiple objects', ->
      AssetUtils.apply(base, characterData.dwarf)
      AssetUtils.apply(base, characterData.bard)
      expect(base.prof_weapon.length).to.equal(9)
      expect(base.prof_tool.length).to.equal(4)

    it 'should correctly join level objects', ->
      AssetUtils.apply(base, characterData.bard)
      AssetUtils.apply(base, characterData.bard._levels[5])
      expect(base.ability[0].die).to.equal(8)



