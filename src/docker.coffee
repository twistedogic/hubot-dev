# Description:
#   Manage your Docker containers with Hubot.
#
# Configuration:
#   HUBOT_DOCKER_HOST - The ip of the docker remote API
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#
# Commands:
#   hubot docker version - Get the docker version information
#   hubot docker ps - Get the running docker containers
#   hubot docker restart <docker_name> - Restart docker container
#
# Author
#   Jordan Li
Docker = require("dockerode")
tablify = require("tablify")
module.exports = (robot) ->
  
  #Functions    
  docker_host = process.env.HUBOT_DOCKER_HOST or "localhost"
  docker_port = process.env.HUBOT_DOCKER_PORT or "4243"
  docker = new Docker(
    host: "http://" + docker_host
    port: docker_port
  )
  docker_request = robot.http("http://" + docker_host)
  robot.docker_version = (callback) ->
    docker_request.path("/version").get() (err, res, body) ->
      return callback(err)  if err isnt null
      callback null, JSON.parse(body)


  robot.docker_ps = (callback) ->
    docker.listContainers (err, containers) ->
      dockertable = []
      return callback(err)  if err isnt null
      containers.forEach (containerInfo) ->
        dockertable.push
          name: containerInfo.Names[0].substring(1)
          id: containerInfo.Id.slice(0, 13)
          status: containerInfo.Status
          image: containerInfo.Image

        return

      callback null, tablify(dockertable)


  robot.docker_restart = (name, callback) ->
    container = docker.getContainer(name)
    container.restart (err, data) ->
      console.log data
      return callback(err.json)  if err isnt null
      callback null, name + " is restarted"


  
  #Respond
  robot.respond /docker version/i, (msg) ->
    robot.docker_version (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      output = "Client version: " + data["Version"] + "\n"
      output += "Client API version: " + data["ApiVersion"] + "\n"
      output += "Go version: " + data["GoVersion"] + "\n"
      output += "Git commit: " + data["GitCommit"] + "\n"
      msg.send output


  robot.respond /docker ps/i, (msg) ->
    robot.docker_ps (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      msg.send data


  robot.respond /docker restart (.*)/i, (msg) ->
    id = msg.match[1]
    robot.docker_restart id, (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      msg.send data


  return