Helper = require('hubot-test-helper')
expect = require('chai').expect
helper = new Helper('../scripts/club-del-cafe.coffee')


#   tito: hay café?             -  Muestra cuantas bolsas quedan sin abrir
describe 'hay café?', ->
  room = null
  queries = null

  say_queries = (room, queries) ->
    for msg, i in queries
      do (msg, i) ->
        room.user.say "user#{i}", "hubot #{msg}"
        room.user.say "user#{i}", "hubot #{msg}?"
        room.user.say "user#{i}", "hubot ¿#{msg}??"
    room.user.say "samus", "WTF coffeescript??" # hubot does not reply without this line

  expect_messages = (queries, reply) ->
    expected_messages = []
    for msg, i in queries
      do (msg, i) ->
        expected_messages.push ["user#{i}", "hubot #{msg}"]
        expected_messages.push ["user#{i}", "hubot #{msg}?"]
        expected_messages.push ["user#{i}", "hubot ¿#{msg}??"]
    expected_messages.push ["samus", "WTF coffeescript??"]
    for msg, i in queries
      do (msg, i) ->
        expected_messages.push ["hubot", "@user#{i} #{reply}"]
        expected_messages.push ["hubot", "@user#{i} #{reply}"]
    expected_messages


  beforeEach ->
    room = helper.createRoom()
    queries = []
    for hay in ['hay', 'queda', 'nos queda', 'tenemos']
      do (hay) ->
        for cafe in ['cafe', 'café', 'coffee', '(c)', '(coffee)']
          do (cafe) ->
            queries.push "#{hay} #{cafe}"
            queries.push "cuanto #{cafe} #{hay}"

  afterEach ->
    room.destroy()


  context '0 bags', ->
    beforeEach ->
      room.robot.brain.data.coffeeBags = 0
      say_queries room, queries

    it 'should reply to the user', ->
      reply = "no quedan bolsas sin abrir"
      expected_messages = expect_messages queries, reply
      expect(room.messages).to.eql expected_messages


  context '1 bags', ->
    beforeEach ->
      room.robot.brain.data.coffeeBags = 1
      say_queries room, queries

    it 'should reply to the user', ->
      reply = "queda una bolsa sin abrir"
      expected_messages = expect_messages queries, reply
      expect(room.messages).to.eql expected_messages


  context '2 bags', ->
    beforeEach ->
      room.robot.brain.data.coffeeBags = 2
      say_queries room, queries

    it 'should reply to the user', ->
      reply = "quedan 2 bolsas sin abrir"
      expected_messages = expect_messages queries, reply
      expect(room.messages).to.eql expected_messages

#   tito: abrimos una bolsa     -  Registra cuando se abre una nueva bolsa de café
#   tito: compramos dos bolsas  -  Registra la compra de nuevas bolsas de café
#   tito: quedan tres bolsas    -  Resetea el conteo de bolsas sin abrir
