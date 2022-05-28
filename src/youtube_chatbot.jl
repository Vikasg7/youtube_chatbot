module youtube_chatbot

include("utils.jl")
include("data.jl")
include("tokens.jl")
include("config.jl")
include("oauth2.jl")
include("youtube.jl")

function main()
   cnfg = Config.read("./config.json")
   rtkn, atkn = OAuth2.get_tokens("./refreshToken.json", cnfg)
   OAuth2.set_atkn!(atkn)

   # Regenerating Access Token at regular intervals
   Timer(3500; interval=3500) do timer
      try
         natkn = OAuth2.renew_access_token(cnfg, rtkn)
         OAuth2.set_atkn!(natkn)
      catch ex
         showerror(stderr, ex, catch_backtrace())
         close(timer)
         exit(1)
      end
   end

   liveChatId = Youtube.get_livechatid()
   msgs = Youtube.get_msgs(liveChatId)

   asyncmap(msgs) do msg
      @show msg
   end
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   youtube_chatbot.main()
end