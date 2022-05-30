module Bots

using URIs
using HTTP

using ..Data

function hi(msg::Data.Msg)::String
   "Hello @$(msg.author)"
end

function weather(msg::Data.Msg)::String
   try
      loc = URIs.escapeuri(join(msg.args, " "))
      resp = HTTP.get("https://wttr.in/$(loc)?format=4")
      return "@$(msg.author) " * String(resp.body)
   catch ex
      showerror(stderr, ex, catch_backtrace())
      "Oops! Error fetching weather."
   end
end

botsTbl = Dict(
   "!hi"      => hi,
   "!weather" => weather
)

end