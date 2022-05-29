module Youtube

using JSON3

using ..Data
using ..OAuth2

LIVEBROADCAST_ENDPOINT = "https://www.googleapis.com/youtube/v3/liveBroadcasts"
CHATMESSAGES_ENDPOINT  = "https://www.googleapis.com/youtube/v3/liveChat/messages"

function get_livechatid()::String
   params = Dict("part"            => "snippet",
                 "broadcastStatus" => "active")
   json = OAuth2.request(:GET, LIVEBROADCAST_ENDPOINT, params)
   item = get(json.items, 1, nothing)
   item === nothing && error("No Live Stream found on the Channel.")
   return item.snippet.liveChatId
end

function get_msgs(liveChatId::String)
   msgs = Channel(2000)
   err  = Channel(1)
   params = Dict("part"       => ["snippet", "authorDetails"],
                 "liveChatId" => liveChatId,
                 "maxResults" => 2000)
   @async while true
      try
         resp = OAuth2.request(:GET, CHATMESSAGES_ENDPOINT, params)
         for item in resp.items
            put!(msgs, item)
         end
         params["pageToken"] = resp.nextPageToken
         sleep(resp.pollingIntervalMillis/1000)
      catch ex
         close(msgs)
         put!(err, (ex, catch_backtrace()))
      end
   end
   return msgs, err
end

function del_msg(msgId::String)
   OAuth2.request(:DELETE, CHATMESSAGES_ENDPOINT, ["id" => msgId])
end

function insert_msg(msg::String, liveChatId::String)
   body = Dict("snippet" => Dict("textMessageDetails" => Dict("messageText" => msg),
                                 "liveChatId"         => liveChatId,
                                 "type"               => "textMessageEvent"))
   OAuth2.request(:POST, CHATMESSAGES_ENDPOINT, ["part" => "snippet"]; body=JSON3.write(body))
end

end