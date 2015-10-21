# Description:
#   Club del café en Sinergia
#
# Commands:
#   tito: hay café?             -  Muestra cuantas bolsas quedan sin abrir
#   tito: abrimos una bolsa     -  Registra cuando se abre una nueva bolsa de café
#   tito: compramos dos bolsas  -  Registra la compra de nuevas bolsas de café
#   tito: quedan tres bolsas    -  Resetea el conteo de bolsas sin abrir
#
# Author:
#   git2samus

module.exports = (robot) ->
  _parseNum = (num) ->
    switch num
      when "un"     then 1
      when "una"    then 1
      when "dos"    then 2
      when "tres"   then 3
      when "cuatro" then 4
      when "cinco"  then 5
      when "seis"   then 6
      else ParseInt(num)

  _getFunds = () ->
    robot.brain.data.coffeeFunds ?= 0
  _setFunds = (funds) ->
    if typeof(funds) is "number"
      robot.brain.data.coffeeFunds = funds
    else
      robot.logger.error "invalid _setFunds argument: #{funds}"

  _getBags = () ->
    robot.brain.data.coffeeBags ?= 0
  _setBags = (bags) ->
    if typeof(bags) is "number" and bags >= 0
      robot.brain.data.coffeeBags = bags
    else
      robot.logger.error "invalid _setBags argument: #{bags}"

  getFunds = () ->
    funds = _getFunds()
    if funds > 0
      "$#{funds} a favor"
    else if bags < 0
      "se deben $#{Math.abs(funds)} de la última compra"
    else
      "sin fondos"

  getBags = () ->
    bags = _getBags()
    if bags > 1
      "quedan #{bags} bolsas sin abrir"
    else if bags > 0
      "queda una bolsa sin abrir"
    else
      "no quedan bolsas sin abrir"

  HAY_RE = "(?:hay|quedan?|ten(?:[eé]|[ií]a(?:mo)?)s)" # hay, queda, quedan, tenes, tenias, teniamos
  ABRIO_RE = "(?:se +(?:abri[oó]|ha +abierto)|abr[ií](?:mos|eron)?)" # se abrio, se ha abierto, abri, abrimos, abrieron
  COMPRAMOS_RE = "(?:compra(?:mos|ron)|tra(?:jeron|imos))" # compramos, compraron, trajeron, trajimos
  CUANTAS_RE = "cuant(?:o|as)" # cuanto, cuantas
  UN_RE = "(?:una?|otr[oa]|la)" # un, una, otro, otra, la
  CAFE_RE = "(?:caf[eé]|coffee|\\(c(?:offee)?\\))" # cafe, coffee, (c), (coffee)
  BOLSAS_RE = "(?:bolsas?(?: +de +#{CAFE_RE})?|(?:bolsas? +de)? +#{CAFE_RE})"
  NUM_RE = "(\\d|una?|dos|tres|cuatro|cinco|seis)"

  # hay café? - Muestra cuantas bolsas quedan sin abrir
  robot.respond new RegExp("¿*(?:#{HAY_RE}(?: +#{BOLSAS_RE})?|#{CUANTAS_RE} +#{BOLSAS_RE} +#{HAY_RE})\\?*", "i"), (res) ->
    res.reply getBags()

  # abrimos una bolsa - Registra cuando se abre una nueva bolsa de café
  robot.respond new RegExp("#{ABRIO_RE} +#{UN_RE} +#{BOLSAS_RE}", "i"), (res) ->
    bags = _getBags()
    if bags > 0
      _setBags(bags - 1)
      res.reply "ok, #{getBags()}"
    else
      res.reply "no tengo más bolsas registradas"

  # compramos dos bolsas - Registra la compra de nuevas bolsas de café
  robot.respond new RegExp("#{COMPRAMOS_RE} +#{NUM_RE} +#{BOLSAS_RE}", "i"), (res) ->
    bags = _getBags()
    newBags = _parseNum(res.match[1])
    _setBags(bags + newBags)
    res.reply "ok, #{getBags()} (favor actualizar fondos)"

  # quedan tres bolsas - Resetea el conteo de bolsas sin abrir
  robot.respond new RegExp("#{HAY_RE} +#{NUM_RE} +#{BOLSAS_RE}", "i"), (res) ->
    newBags = _parseNum(res.match[1])
    _setBags(newBags)
    res.reply "ok, #{getBags()}"
