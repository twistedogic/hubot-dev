# Description:
#   Create ngrok tunnel with Hubot.
#
# Configuration:
#   HUBOT_DOCKER_HOST - The ip of the docker remote API
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#   HUBOT_DOCKER_SOCKET - The socket path of docker (Default:/var/run/docker.sock)
#
# Commands:
#   hubot tunnel create <ip:port> - create ngrok container for ip:port 
#   hubot tunnel remove - remove all running ngrok container
#
# Author
#   Jordan Li
tunnel = require('../lib/tunnel')

module.exports = (robot) ->

  robot.create_tunnel = (input, callback) ->
    tunnel input, (err, data) ->
      callback null, data

  robot.remove_tunnel = (callback) ->
    tunnel 'remove', (err, data) ->
      callback null, data

  robot.respond /tunnel remove/i, (msg) ->
    robot.remove_tunnel (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  robot.respond /tunnel create (.*)/i, (msg) ->
    id = undefined
    id = msg.match[1]
    robot.create_tunnel id, (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  return
