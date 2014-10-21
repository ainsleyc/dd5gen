fs = require 'fs'

assetGroups = [
  {
    path: './assets/character'
    target: './public/assets/character.json'
  },
  {
    path: './assets/lists'
    target: './public/assets/lists.json'
  }
]

processDir = (files, path) ->
  for file in files
    nextPath = "#{path}/#{file}"
    if fs.lstatSync(nextPath).isDirectory()
      processDir(fs.readdirSync(nextPath), nextPath)
    else
      json = JSON.parse(fs.readFileSync(nextPath, 'utf8'))
      type = json.type
      delete json.type
      results[type] = json

for group in assetGroups
  results = {}
  assets = fs.readdirSync(group.path, 'utf8')
  processDir(assets, group.path)
  console.log("Generating #{group.target}")
  fs.writeFileSync(group.target, JSON.stringify(results))

