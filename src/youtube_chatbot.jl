# module youtube_chatbot

include("utils.jl")
include("data.jl")
include("tokens.jl")
include("config.jl")
include("oauth2.jl")
include("youtube.jl")

function main()
   cnfg = Config.read("./config.json")
   rtkn, atkn = OAuth2.get_tokens("./rtkn.json", cnfg)
   OAuth2.set_atkn!(atkn)
   @info "->" rtkn OAuth2.atkn[]

   # a = Timer(0; interval=100) do t
   #    natkn = OAuth2.renew_access_token(cnfg, rtkn)
   #    OAuth2.setatkn!(atkn)
   # end

end

# end

# function test()
#    Timer(0) do t
#       sleep(2)
#       error("Error inside timer!")
#    end
#    sleep(10)
#    @info "test ends!"
# end

# test()