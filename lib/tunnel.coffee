_ = require('lodash')
Docker = require('dockerode')
async = require('async')
Is = require('is_js')
exports = module.exports = {}
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

exports.create = (input, callback) ->
  if Is.ipv4(input.split(':')[0])
    console.log input
    docker.createContainer {
      Image: 'wizardapps/ngrok:latest'
      Cmd: [
        'ngrok'
        '-log=stdout'
        input
      ]
    }, (err, res) ->
      if !err
        container = docker.getContainer(res.id)
        container.start (err, data) ->
          container.attach {
            stream: true
            stdout: true
            stderr: true
          }, (err, stream) ->
            stream.on 'data', (buf) ->
              `var data`
              data = buf.toString()
              if data.indexOf('.ngrok.com') > -1
                url = data.split('.ngrok.com')[0].split('http')[1]
                url = 'http' + url + '.ngrok.com'
                callback null, url
                stream.emit 'end'
              return
            return
          return
      return
  else
    callback 'input valid ipv4'
  return

stopAndRemove = (input, callback) ->
  container = undefined
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

exports.remove = (callback) ->
  `var options`
  options = undefined
  docker.listContainers { all: true }, (err, containers) ->
    image = undefined
    list = undefined
    status = undefined
    list = []
    _.each containers, (n) ->
      image = n.Image
      status = n.Status
      if image.indexOf('ngrok') > -1 and status.indexOf('Exited') == -1
        list.push n.Id
      return
    async.map list, stopAndRemove, (err, res) ->
      if err
        callback err
      else
        callback null, 'removed'
      return
    return
  return
