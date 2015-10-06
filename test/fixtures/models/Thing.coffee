module.exports = (m)->
  type = m.type
  r    = m.r

  Thing = m.createModel 'Things', {
    name    : type.string()
    data    : type.object()
  }
  return Thing