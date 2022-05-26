module Youtube

using ..Data
using ..OAuth2

LIVEBROADCAST_ENDPOINT = "https://www.googleapis.com/youtube/v3/liveBroadcasts"
CHATMESSAGES_ENDPOINT  = "https://www.googleapis.com/youtube/v3/liveChat/messages"

function get_livechatid()::String
   params = Dict("part" => "snippet",
                 "mine" => "true")
   json = OAuth2.request(:GET, LIVEBROADCAST_ENDPOINT, [], params)
   item = get(json.items, 1, nothing)
   item === nothing && error("No Live Stream found on the Channel.")
   return item.snippet.liveChatId
end

function get_msgs(livechatid::String)

end

function del_msg(msgId::String)
   OAuth2.request(:DELETE, CHATMESSAGES_ENDPOINT, [], ["id" => msgId])
end

function insert_msg(msg::String, liveChatId::String)
   body = Dict("snippet" => Dict("textMessageDetails" => Dict("messageText" => msg),
                                 "liveChatId"         => liveChatId,
                                 "type"               => "textMessageEvent"))
   OAuth2.request(:POST, CHATMESSAGES_ENDPOINT, body, ["part" => "snippet"])
end

end