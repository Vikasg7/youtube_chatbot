module Data

struct Config
   clientId::String
   clientSecret::String
   scopes::Vector{String}
   redirectUrl::String
   botname::String
end

struct AccessToken
   access_token::String
   expires_in::Int64
   scope::String
   token_type::String
end

const RefreshToken = String 

const Tokens = Tuple{RefreshToken, AccessToken}

struct Msg
   liveChatId::String
   text::String
   cmd::String
   args::Vector{String}
   msgId::String
   sender::String
   isMod::Bool
   isOwner::Bool
   isSponsor::Bool
   Msg(msg) = begin
      cmd, args... = split(lowercase(msg.snippet.displayMessage), " ")
      new(msg.snippet.liveChatId,
          msg.snippet.displayMessage,
          cmd,
          args,
          msg.id,
          msg.authorDetails.displayName,
          msg.authorDetails.isChatModerator,
          msg.authorDetails.isChatOwner,
          msg.authorDetails.isChatSponsor)
   end
end

end