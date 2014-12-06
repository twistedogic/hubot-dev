# Description:
#   Get realtime data from aastock.com
#
# Configuration:
#   None
#
# Commands:
#   hubot hkstock index - Get all HK indices
#   hubot hkstock news <symbol> - Get the realtime news about the specified symbol
#   hubot hkstock quote <symbol> - Get the realtime quote of the specified symbol
#
# Author
#   Jordan Li
YQL = require("yql")
tablify = require("tablify")
module.exports = (robot) ->
  
  #Functions    
  robot.hkstock_index = (callback) ->
    base_aaurl = "http://www.aastocks.com/en/stocks/market/index/hk-index.aspx"
    xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"float_\", \" \" ))] | //*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"r\", \" \" ))]"
    query = new YQL("select * from html where url=\"" + base_aaurl + "\" and xpath=" + "'" + xpath + "'")
    query.exec (error, response) ->
      indexTable = []
      unless error
        data = response.query.results
        indexTable.push [
          "index"
          data.th[0].p.content
          data.th[1].p
          data.th[2].p
          data.th[3].p.content
          data.th[4].p
          data.th[5].p
          data.th[6].p
        ]
        j = 0

        while j < data.div.length
          indexTable.push [
            data.div[j].p
            data.td[7 * j].div[1].p
            data.td[7 * j + 1].strong.span.content
            data.td[7 * j + 2].strong.span.content
            data.td[7 * j + 3].p
            data.td[7 * j + 4].p
            data.td[7 * j + 5].p
            data.td[7 * j + 6].strong.span.content
          ]
          j++
      callback null, tablify(indexTable,
        has_header: true
      )


  
  # Do something with results (response.query.results)
  robot.hkstock_news = (symbol, callback) ->
    base_aaurl = "http://www.aastocks.com/tc/stocks/analysis/stock-aafn/" + symbol + "/0/all/1"
    xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"h6\", \" \" ))]"
    query = new YQL("select * from html where url=\"" + base_aaurl + "\" and xpath=" + "'" + xpath + "'")
    query.exec (error, response) ->
      unless error
        data = response.query.results
        table = [title: data.a[0].title]
        j = 1

        while j < data.a.length
          table.push title: data.a[j].title
          j++
        callback null, tablify(table)


  
  # Do something with results (response.query.results)
  robot.hkstock_quote = (symbol, callback) ->
    base_aaurl = "http://www.aastocks.com/en/LTP/RTQuote.aspx?symbol=" + symbol
    xpath = "//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"bold\", \" \" ))]//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"bold\", \" \" ))] | //*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"C\", \" \" ))]//strong"
    query = new YQL("select * from html where url=\"" + base_aaurl + "\" and xpath=" + "'" + xpath + "'")
    query.exec (error, response) ->
      unless error
        data = response.query.results
        table = []
        if data.span[0].class.split(" ")[0] is "neg"
          table.push
            sybmol: symbol
            last: data.span[0].content
            change: "-" + data.span[1].content
            range: data.strong

        else
          table.push
            sybmol: symbol
            last: data.span[0].content
            change: "+" + data.span[1].content
            range: data.strong

        callback null, tablify(table)


  
  # Do something with results (response.query.results)
  
  #Respond
  robot.respond /hkstock index/i, (msg) ->
    robot.hkstock_index (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      msg.send data


  robot.respond /hkstock news (.*)/i, (msg) ->
    symbol = msg.match[1] or "0001"
    robot.hkstock_news symbol, (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      msg.send data


  robot.respond /hkstock quote (.*)/i, (msg) ->
    symbol = msg.match[1] or "0001"
    robot.hkstock_quote symbol, (err, data) ->
      return msg.reply("Sorry, there was an error: " + err)  if err isnt null
      msg.send data


  return