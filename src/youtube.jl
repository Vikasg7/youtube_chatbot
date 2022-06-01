module Youtube

using JSON3

using ..Data
using ..OAuth2
using ..Bots
using ..Filters

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

function get_msgs(liveChatId::String)::Channel{Data.Msg}
   params = Dict("part"       => ["snippet", "authorDetails"],
                 "liveChatId" => liveChatId,
                 "maxResults" => 2000)
   Channel{Data.Msg}(2000) do msgs
      while true
         resp = OAuth2.request(:GET, CHATMESSAGES_ENDPOINT, params)
         for item in resp.items
            put!(msgs, Data.Msg(item))
         end
         params["pageToken"] = resp.nextPageToken
         sleep((resp.pollingIntervalMillis+100)/1000)
      end
   end
end

function del_msg(msgId::String)
   OAuth2.request(:DELETE, CHATMESSAGES_ENDPOINT, ["id" => msgId])
end

function insert_msg(text::String, liveChatId::String)
   body = Dict("snippet" => Dict("textMessageDetails" => Dict("messageText" => text),
                                 "liveChatId"         => liveChatId,
                                 "type"               => "textMessageEvent"))
   OAuth2.request(:POST, CHATMESSAGES_ENDPOINT, ["part" => "snippet"]; body=JSON3.write(body))
end

function process_msg(botname::String, msg::Data.Msg)
   msg.sender == botname && return nothing 
   bot = get(Bots.botsTbl, msg.cmd, nothing)
   if bot !== nothing
      reply = bot(msg)
      reply !== nothing && 
         insert_msg(reply, msg.liveChatId)
   end
end

end