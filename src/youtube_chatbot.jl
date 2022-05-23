module youtube_chatbot

include("utils.jl")
include("data.jl")
include("token.jl")
include("config.jl")
include("oauth2.jl")

function main()
   cnfg = Config.read("./config.json")
   code = OAuth2.get_authorization_code(cnfg)
   json = OAuth2.get_access_token(cnfg, code)
   @info "->" code json
end

end
