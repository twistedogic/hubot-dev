# Description:
#   Manage your Docker containers with Hubot.
#
# Configuration:
#   HUBOT_DOCKER_HOST - The ip of the docker remote API
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#
# Commands:
#   hubot docker ps - Get the running docker containers
#   hubot docker restart <docker_name> - Restart docker container
#
# Author
#   Jordan Li
Docker = require('dockerode')
tablify = require('tablify')

module.exports = (robot) ->
  `var options`
  if process.env.HUBOT_DOCKER_HOST
    options = 
      host: process.env.HUBOT_DOCKER_HOST
      port: process.env.HUBOT_DOCKER_PORT
      timeout: 10000
  else
    options = 
      socketPath: process.env.HUBOT_DOCKER_SOCKET or '/var/run/docker.sock'
      timeout: 10000
  docker = new Docker(options)

  robot.docker_ps = (callback) ->
    docker.listContainers (err, containers) ->
      dockertable = []
      if err != null
        return callback(err)
      containers.forEach (containerInfo) ->
        json = 
          name: containerInfo.Names[0].substring(1)
          id: containerInfo.Id.slice(0, 13)
          status: containerInfo.Status
          image: containerInfo.Image
        docker.getContainer(containerInfo.Id).inspect (err, res) ->
          json.ip = res.NetworkSettings.IPAddress
          return
        dockertable.push json
        return
      callback null, tablify(dockertable)

  robot.docker_restart = (name, callback) ->
    container = docker.getContainer(name)
    container.restart (err, data) ->
      console.log data
      if err != null
        return callback(err.json)
      callback null, name + ' is restarted'

  robot.respond /docker ps/i, (msg) ->
    robot.docker_ps (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  robot.respond /docker restart (.*)/i, (msg) ->
    id = undefined
    id = undefined
    id = msg.match[1]
    robot.docker_restart id, (err, data) ->
      if err != null
        return msg.reply('Sorry, there was an error: ' + err)
      msg.send data
  return

