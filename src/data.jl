module Data

struct Config
   clientId::String
   clientSecret::String
   scopes::Vector{String}
   redirectUrl::String
end

mutable struct Token
   access_token::String
   expires_in::Int64
   refresh_token::String
   scope::String
   token_type::String
end

end