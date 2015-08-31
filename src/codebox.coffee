# Description:
#   Create codebox container with Hubot.
#
# Configuration:
#   HUBOT_DOCKER_HOST - The ip of the docker remote API
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#   HUBOT_DOCKER_SOCKET - The socket path of docker (Default:/var/run/docker.sock)
#
# Commands:
#   hubot codebox create - create codebox container
#   hubot codebox remove - remove running codebox container
#
# Author
#   Jordan Li
codebox = require('../lib/codebox')
tablify = require('tablify')

module.exports = (robot) ->

  robot.create_codebox = (input, callback) ->
    codebox.create input, (err, data) ->
      callback null, tablify(data)

  robot.remove_codebox = (callback) ->
    tunnel.remove (err, data) ->
      callback null, data

  robot.respond /codebox remove/i, (msg) ->
    robot.remove_codebox (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  robot.respond /codebox create/i, (msg) ->
    id = msg.match[1]
    robot.create_codebox (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  return
