module Data

struct Config
   clientId::String
   clientSecret::String
   scopes::Vector{String}
   redirectUrl::String
end

end