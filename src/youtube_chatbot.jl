module youtube_chatbot

include("utils.jl")
include("data.jl")
include("config.jl")
include("oauth2.jl")

function main()
   cfg = Config.read("./config.json")
   code = OAuth2.get_authorization_code(cfg)
   @info code
end

end
