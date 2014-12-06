# Description:
#   Manage syslog.
#
# Configuration:
#   HUBOT_ES_HOST - The ip of the elasticsearch
#   HUBOT_DOCKER_PORT - The port of the docker remote API
#
# Commands:
#   hubot search <query> limit <no_of_results> - Get the logs
#
# Author
#   Jordan Li
tablify = require("tablify")
module.exports = (robot) ->
  
  #Functions    
  es_host = process.env.HUBOT_ES_HOST or "localhost:9200"
  es_request = robot.http("http://" + es_host)
  robot.logSearch = (query, limit, callback) ->
    data = JSON.stringify(
      query:
        filtered:
          query:
            bool:
              should: [query_string:
                query: query
              ]

          filter:
            bool:
              must: [match_all: {}]

      size: limit
      sort: ["@timestamp":
        order: "desc"
        ignore_unmapped: true
      ]
    )
    es_request.path("/_search?").headers("X-Requested-With": "XMLHttpRequest").get(data) (err, res, body) ->
      if err isnt null
        return callback(err)
      else
        data = body.hits.hits
        table = []
        data.forEach (info) ->
          table.push
            name: info._source.program
            time: info._source.timestamp
            log: info._source.message

          return

      callback null, tablify(table)


  
  #Respond
  robot.respond /search (.*) limit ([0-9]*) /i, (msg) ->
    query = msg.match[1] or "*"
    limit = msg.match[2] or 5
    robot.logSearch query, limit, (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      data = body.hits.hits
      table = []
      data.forEach (info) ->
        table.push
          name: info._source.program
          time: info._source.timestamp
          log: info._source.message

        return

      msg.send tablify(table)


  return