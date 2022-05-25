module youtube_chatbot

include("utils.jl")
include("data.jl")
include("tokens.jl")
include("config.jl")
include("oauth2.jl")

function main()
   cnfg = Config.read("./config.json")
   (rtkn, atkn) = OAuth2.get_access_token("./rtkn.json", cnfg)
   @info "->" rtkn atkn
end

end
