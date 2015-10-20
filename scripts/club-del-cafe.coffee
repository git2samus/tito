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
      when "una"    then 1
      when "dos"    then 2
      when "tres"   then 3
      when "cuatro" then 4
      when "cinco"  then 5
      when "seis"   then 6
      else ParseInt(num)

  _getBags = () ->
    robot.brain.data.numBags ?= 0
  _setBags = (bags) ->
    if typeof(bags) is "number" and bags >= 0
      robot.brain.data.numBags = bags
    else
      robot.logger.error "invalid setBags argument: #{bags}"

  getBags = () ->
    bags = _getBags()
    if bags > 1
      "quedan #{bags} bolsas sin abrir"
    else if bags > 0
      "queda una bolsa sin abrir"
    else
      "no quedan bolsas sin abrir"

  robot.respond /¿*(hay|quedan?|ten(é|(e|ía)(mo)?)s|cuant(o|as))( +bolsas)?( +de)?( +(caf(e|é)|coffee|\(c(offee)?\)))?\?*/i, (res) ->
    res.reply getBags()
  robot.respond /¿*cuant(o|as)( +bolsas)?( +de)?( +(caf(e|é)|coffee|\(c(offee)?\)))? +(hay|quedan?|ten(é|(e|ía)(mo)?)s)\?*/i, (res) ->
    res.reply getBags()

  robot.respond /(se +abri(ó|o)|abr(í|i)(mos|eron)?) +(una|otra) +bolsa( +de +(caf(e|é)|coffee|\(c(offee)?\)))?/i, (res) ->
    bags = _getBags()
    if bags > 0
      _setBags(bags - 1)
      res.reply "ok, #{getBags()}"
    else
      res.reply "no tengo más bolsas registradas"

  robot.respond /(compra(mos|ron)|tra(jeron|imos)) +(\d|una|dos|tres|cuatro|cinco|seis) +bolsas?( +de +(caf(e|é)|coffee|\(c(offee)?\)))?/i, (res) ->
    bags = _getBags()
    newBags = _parseNum(res.match[4])
    _setBags(bags + newBags)
    res.reply "ok, #{getBags()}"

  robot.respond /(hay|quedan?|ten(é|e(mo)?)s) +(\d|una|dos|tres|cuatro|cinco|seis) +bolsas?( +de +(caf(e|é)|coffee|\(c(offee)?\)))?/i, (res) ->
    newBags = _parseNum(res.match[4])
    _setBags(newBags)
    res.reply "ok, #{getBags()}"
