Docker = require('dockerode')
async = require('async')
Is = require('is_js')

createPresent = (input, callback) ->
  docker.createContainer {
    Image: 'twistedogic/revealjs'
    Cmd: [
      '/nodejs/bin/node'
      'app.js'
      input
    ]
  }, (err, container) ->
    container.start {}, (err, data) ->
      if err
        callback err
      else
        container.inspect (err, res) ->
          if err
            callback err
          else
            callback null, res.NetworkSettings.IPAddress
          return
      return
    return
  return

stopAndRemove = (input, callback) ->
  container = docker.getContainer(input)
  container.stop (err, r) ->
    if err
      callback err
    else
      container.remove { v: 1 }, (e, d) ->
        if e
          callback e
        else
          callback null, input
        return
    return
  return

deletePresent = (callback) ->
  `var options`
  docker.listContainers { all: true }, (err, containers) ->
    i = undefined
    image = undefined
    list = undefined
    status = undefined
    list = []
    i = 0
    while i < containers.length
      image = containers[i].Image
      status = containers[i].Status
      if image.indexOf('revealjs') > -1 and status.indexOf('Exited') == -1
        list.push containers[i].Id
      i++
    async.map list, stopAndRemove, (err, res) ->
      if err
        callback err
      else
        callback null, 'removed'
      return
    return
  return

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

module.exports = (input, callback) ->
  if input == 'remove'
    deletePresent (e, r) ->
      callback e, r
      return
  else
    createPresent input, (e, r) ->
      callback e, r
      return
  return
