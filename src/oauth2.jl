module OAuth2

using HTTP
using URIs
using Sockets
using DefaultApplication

using ..Utils
using ..Data

const AUTH_ENPOINT  = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_ENPOINT = "https://oauth2.googleapis.com/token"

function get_auth_url(config::Data.Config)::String
   params = Dict("redirect_uri"  => config.redirectUrl,
                 "client_id"     => config.clientId,
                 "access_type"   => "offline",
                 "scope"         => join(config.scopes, " "),
                 "prompt"        => "select_account",
                 "response_type" => "code")
   return URI(URI(AUTH_ENPOINT); query=params) |> string
end

struct AuthFailed <: Exception
   msg::String
end

function await_authorization_code(redirectUrl::String)
   url = URI(redirectUrl)
   # resolving localhost to ip"127.0.0.1"
   host = Sockets.getalladdrinfo(url.host) |> last
   port = parse(Int, url.port)
   chnl = Channel(1)
   # providing own socket to be able to close(server)
   srvr = Sockets.listen(Sockets.InetAddr(host, port))
   @async HTTP.serve(; server=srvr) do req
      params = queryparams(URI(req.target))
      error = get(params, "error", nothing)
      if error !== nothing
         put!(chnl, AuthFailed(error))
         return HTTP.Response("Sorry, couldn't Authenticate. Reason:- $(error)")
      end
      code = get(params, "code", nothing)
      # just in case, if code is nothing
      if code === nothing
         put!(chnl, AuthFailed("Code is undefined"))
         return HTTP.Response("Sorry, couldn't Authenticate. Reason:- Code is undefined")
      end
      put!(chnl, code)
      HTTP.Response("Authenticated with code:- $(code)")
   end
   rslt = fetch(chnl)
   close(srvr)
   rslt isa AuthFailed && throw(rslt)
   return rslt
end

function get_authorization_code(config::Data.Config)::String
   url = get_auth_url(config)
   @info "Authentication Url: $url"
   escUrl = Utils.escapeAmpersand(url)
   DefaultApplication.open(escUrl; wait=true)
   code = await_authorization_code(config.redirectUrl)
   @info "Authorization Code: $code"
   return code
end

function get_access_token(code)

end

function renew_access_token(token)

end

end