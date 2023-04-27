module Bots

using URIs
using HTTP

using ..Data

function hi(msg::Data.Msg)::String
   "Hello @$(msg.sender)"
end

function weather(msg::Data.Msg)::String
   try
      loc = URIs.escapeuri(join(msg.args, " "))
      resp = HTTP.get("https://wttr.in/$(loc)?format=4")
      return "@$(msg.sender) " * String(resp.body)
   catch
      "Oops! Error fetching weather."
   end
end

ls = Ref([])

function list(msg::Data.Msg)::Union{Nothing, String}
   try
      if isempty(msg.args)
         isempty.(ls) && 
            return "@$(msg.sender) List is empty right now. Type [ !list me ] to add yourself to the list."
         return "List - [ " * join.(ls, ", ") * " ]"
      end
      subcmd, args... = msg.args
      if subcmd == "me"
         msg.sender .∈ ls &&
            return "@$(msg.sender) You are already in the list."
         push!.(ls, msg.sender)
         return "Added @$(msg.sender) to the list."
      end
      if (subcmd == "next") & msg.isOwner
         isempty.(ls) &&
            return "@$(msg.sender) List is empty."
         n = parse(Int, get(args, 1, "1"))
         n = n > length.(ls) ? length.(ls) : n
         nextup = splice!.(ls, 1:n)
         return "@$(join(nextup, " @")) You are up next. Ready up! Join the team."
      end
      if (subcmd == "off") & msg.isOwner
         takenOff = filter(.∈(ls), replace.(args, "@" => ""))
         filter!.(∉(takenOff), ls)
         isempty(takenOff) &&
            return "@$(msg.sender) Nobody was taken off from the list."
         return "@$(join(takenoff, " @")) taken off from the list."
      end
      if subcmd == "off"
         msg.sender .∉ ls &&
            return "@$(msg.sender) You are not in the list."
         filter!.(∉([msg.sender]), ls)
         return "Took @$(msg.sender) off from the list."
      end
   catch ex
      showerror(stderr, ex, catch_backtrace())
      "Error while processing !list command."
   end
end

botsTbl = Dict(
   "!hi"      => hi,
   "!weather" => weather,
   "!list"    => list
)

end