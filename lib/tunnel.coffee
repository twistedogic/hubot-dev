Docker = require('dockerode')
async = require('async')
Is = require('is_js')
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

createTunnel = (input, callback) ->
  docker.createContainer {
    Image: 'wizardapps/ngrok:latest'
    Cmd: [
      'ngrok'
      '-log'
      'stdout'
      input
    ]
  }, (err, container) ->
    container.start {}, (err, data) ->
      if err
        callback err
      else
        container.attach {
          stream: true
          stdout: true
          stderr: true
        }, (err, stream) ->
          if err
            callback err
          else
            stream.setEncoding 'utf8'
            stream.on 'data', (buf) ->
              `var data`
              data = buf.split('established at http://')[1]
              if data
                callback null, data.split('\n')[0]
                @emit 'end'
              return
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

deleteTunnel = (callback) ->
  `var options`
  docker.listContainers { all: true }, (err, containers) ->
    list = []
    i = 0
    while i < containers.length
      image = containers[i].Image
      status = containers[i].Status
      if image.indexOf('ngrok') > -1 and status.indexOf('Exited') == -1
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

module.exports = (input, callback) ->
  if input == 'remove'
    deleteTunnel (e, r) ->
      callback e, r
      return
  else
    if Is.ipv4(input.split(':')[0])
      createTunnel input, (e, r) ->
        callback e, r
        return
    else
      callback null, 'Please input container IP'
  return

# ---
# generated by js2coffee 2.1.0