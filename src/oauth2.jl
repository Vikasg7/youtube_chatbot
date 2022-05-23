module OAuth2

using HTTP
using URIs
using Sockets
using DefaultApplication
using JSON3

using ..Utils
using ..Data
using ..Token

const AUTH_ENPOINT  = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_ENPOINT = "https://oauth2.googleapis.com/token"

function get_auth_url(cnfg::Data.Config)::String
   params = Dict("redirect_uri"  => cnfg.redirectUrl,
                 "client_id"     => cnfg.clientId,
                 "access_type"   => "offline",
                 "scope"         => join(cnfg.scopes, " "),
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
         return HTTP.Response("Authentication failed. Reason:- $(error)")
      end
      code = get(params, "code", nothing)
      # just in case, if code is nothing
      if code === nothing
         put!(chnl, AuthFailed("Code is undefined"))
         return HTTP.Response("Authentication failed. Reason:- Code is undefined")
      end
      put!(chnl, code)
      HTTP.Response("Authenticated with code:- $(code)")
   end
   rslt = fetch(chnl)
   close(srvr)
   rslt isa AuthFailed && throw(rslt)
   return rslt
end

function get_authorization_code(cnfg::Data.Config)::String
   url = get_auth_url(cnfg)
   @info "Authentication Url: $url"
   escUrl = Utils.escapeAmpersand(url)
   DefaultApplication.open(escUrl; wait=true)
   code = await_authorization_code(cnfg.redirectUrl)
   @info "Authorization Code: $code"
   return code
end

function get_access_token(cnfg::Data.Config, code::String)::Data.Token
   hdrs = ["Content-Type" => "application/x-www-form-urlencoded"]
   prts = Dict("code"          => code,
               "redirect_uri"  => cnfg.redirectUrl,
               "client_id"     => cnfg.clientId,
               "client_secret" => cnfg.clientSecret,
               "scope"         => join(cnfg.scopes, " "),
               "grant_type"    => "authorization_code")
   # [2:end] for removing the ? infront
   body = string(URI(;query=prts))[2:end]
   resp = HTTP.post(TOKEN_ENPOINT, hdrs, body)
   @info "->" String(resp.body)
   tokn = resp.body |> String |> JSON3.read |> Token.read
   tokn.expires_in = floor(Int64, Dates.time()) + tokn.expires_in
   return tokn
end

function renew_access_token(tokn::Data.Token)

end

function request()

end

end