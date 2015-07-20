# Description:
#   Create ngrok tunnel with Hubot.
#
# Configuration:
#   HUBOT_DOCKER_HOST - The ip of the docker remote API
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#   HUBOT_DOCKER_SOCKET - The socket path of docker (Default:/var/run/docker.sock)
#
# Commands:
#   hubot present create <slideshare url> - create revealjs container for slideshare url 
#   hubot present remove - remove all running revealjs container
#
# Author
#   Jordan Li
present = require('../lib/present')

module.exports = (robot) ->

  robot.create_present = (input, callback) ->
    present input, (err, data) ->
      callback null, data

  robot.remove_present = (callback) ->
    present 'remove', (err, data) ->
      callback null, data

  robot.respond /present remove/i, (msg) ->
    robot.remove_present (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  robot.respond /present create (.*)/i, (msg) ->
    id = msg.match[1]
    robot.create_present id, (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  return
