module youtube_chatbot

include("utils.jl")
include("data.jl")
include("tokens.jl")
include("config.jl")
include("oauth2.jl")
include("filters.jl")
include("bots.jl")
include("youtube.jl")

function main()
   cnfg = Config.read("./config.json")
   rtkn, atkn = OAuth2.get_tokens("./refreshToken.json", cnfg)
   OAuth2.set_atkn!(atkn)

   # Regenerating Access Token at regular intervals
   a = @async Utils.timer(3500; interval=3500) do
      natkn = OAuth2.renew_access_token(cnfg, rtkn)
      OAuth2.set_atkn!(natkn)
   end

   liveChatId = Youtube.get_livechatid()
   msgs, msgerr = Youtube.get_msgs(liveChatId)

   # Processing messages
   b = @async asyncmap(Youtube.process_msg, msgs)

   ex, bt = Utils.raceError(a, b, msgerr)
   showerror(stderr, ex, bt)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   youtube_chatbot.main()
end