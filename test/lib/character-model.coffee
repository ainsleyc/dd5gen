fs = require 'fs'
should = require('chai').should()
characterData = JSON.parse(fs.readFileSync('./public/assets/character.json', 'utf-8'))

describe 'CharacterModel', ->
  describe 'inititalization', ->
    it 'should have a test', ->

