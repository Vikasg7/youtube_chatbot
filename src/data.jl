module Data

struct Config
   clientId::String
   clientSecret::String
   scopes::Vector{String}
   redirectUrl::String
end

mutable struct AccessToken
   access_token::String
   expires_in::Int64
   scope::String
   token_type::String
end

const RefreshToken = String 

const Tokens = Tuple{RefreshToken, AccessToken}

end