
class AssetUtils

  COMMANDS:
    $adjust: true
    $set: true
    $add: true
    $choose: true

  FIELD_BLACKLIST:
    _levels: true

  getPath: (obj, path) =>
    tokens = path.split('.')
    ptr = obj
    for token in tokens
      if not ptr?
        return null
      else
        if ptr instanceof Array
          next = null
          for p in ptr
            if p.id is token
              next = p
          ptr = next
        else
          ptr = ptr[token]
    return ptr

  apply: (target, merge) =>
    for path, ops of merge
      if not @FIELD_BLACKLIST[path]?
        ptr = @_getPtr(target, path)
        orig = ptr.base[ptr.key]
        for op, block of ops
          if @COMMANDS[op]?
            ptr.base[ptr.key] = @["_#{op}"](orig, block)

  _$choose: () =>
    return {}

  _$set: (orig, merge) =>
    return merge

  _$add: (orig, merge) =>
    if not(orig instanceof Array) or not(merge instanceof Array)
      throw new Error("AssetUtils.$add: invalid datatypes")
    else
      for val in merge
        orig.push(val)
      return orig

  _$adjust: (orig, merge, level = 0) =>
    if merge.const?
      orig.value += merge.const
    return orig

  _getPtr: (obj, path) =>
    tokens = path.split('.')
    if tokens.lenght is 1
      return { base: obj, key: path }
    else
      ptr = obj
      prev = null
      for token in tokens
        if not ptr?
          return null
        else
          prev = ptr
          if ptr instanceof Array
            next = null
            for p in ptr
              if p.id is token
                next = p
            ptr = next
          else
            ptr = ptr[token]
      return { base: prev, key: tokens[tokens.length-1] }

if typeof module?.exports isnt 'undefined'
  module.exports = new AssetUtils
