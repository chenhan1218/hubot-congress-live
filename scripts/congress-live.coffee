# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot youtube me <query> - Searches YouTube for the query and returns the video embed link.
csv = require('csv');
async = require('async')

module.exports = (robot) ->
  AsyncVideoLibrary =
    fetch: (row, callback) ->
      if (id = row[0].match(/youtube.com\/embed\/(.*)/))
        robot.http("https://www.googleapis.com/youtube/v3/videos")
          .query({
            part: "id,snippet,liveStreamingDetails"
            id: id[1]
            key: process.env.HUBOT_GOOGLE_APIS_KEY
          })
          .get() (err, res, body) ->
            metadata = JSON.parse(body)
            liveStatus = metadata.items[0].snippet.liveBroadcastContent
            callback(null, [liveStatus=='live', row[1], "@youtube"])
      else if (id = row[0].match(/ustream.tv\/embed\/(.*)/))
        robot.http("http://api.ustream.tv/json/channel/"+id[1]+"/getValueOf/status")
          .get() (err, res, body) ->
            metadata = JSON.parse(body)
            liveStatus = metadata.results
            callback(null, [liveStatus=='live', row[1], "@ustream.tv"])
      else
        callback(null, [])

  robot.respond /(congress)( live)$/i, (msg) ->
    robot.http("https://ethercalc.org/_/congressoccupied/csv")
      .query({
      })
      .get() (err, res, body) ->
        csv().from.string(
          body,
          {comment: '#'}
        ).to.array (url_list) ->
          async.map( url_list, AsyncVideoLibrary.fetch.bind(AsyncVideoLibrary), (err, result) ->
            result.filter( (message)-> message!=[] and message[0]).map( (message)->
              msg.send(message[1] + ' ' + message[2])
            )
          )
