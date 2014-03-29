# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot youtube me <query> - Searches YouTube for the query and returns the video embed link.
csv = require('csv');

module.exports = (robot) ->
  robot.respond /(congress)( live)$/i, (msg) ->
    robot.http("https://ethercalc.org/_/congressoccupied/csv")
      .query({
      })
      .get() (err, res, body) ->
        csv().from.string(
          body,
          {comment: '#'}
        ).to.array (url_list) ->
          url_list.map (row, idx) ->
            id = row[0].match(/youtube.com\/embed\/(.*)/)
            if id
              robot.http("https://www.googleapis.com/youtube/v3/videos")
                .query({
                  part: "id,snippet,liveStreamingDetails"
                  id: id[1]
                  key: process.env.HUBOT_GOOGLE_APIS_KEY
                })
                .get() (err, res, body) ->
                  metadata = JSON.parse(body)
                  liveStatus = metadata.items[0].snippet.liveBroadcastContent
                  if liveStatus=='live'
                    msg.send("Row" + idx + ' ' + row[1] + ' ' + "@youtube")
            id = row[0].match(/ustream.tv\/embed\/(.*)/)
            if id
              robot.http("http://api.ustream.tv/json/channel/"+id[1]+"/getValueOf/status")
                .get() (err, res, body) ->
                  metadata = JSON.parse(body)
                  liveStatus = metadata.results
                  if liveStatus=='live'
                    msg.send("Row" + idx + ' ' + row[1] + ' ' + "@ustream.tv")
