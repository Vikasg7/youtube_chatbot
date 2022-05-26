module OAuth2

using HTTP
using URIs
using Sockets
using DefaultApplication
using JSON3

using ..Utils
using ..Data
using ..Tokens

const AUTH_ENDPOINT  = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"

atkn = Ref{Data.AccessToken}()

function set_atkn!(natkn::Data.AccessToken)
   atkn[] = natkn
end

function get_auth_url(cnfg::Data.Config)::String
   params = Dict("redirect_uri"  => cnfg.redirectUrl,
                 "client_id"     => cnfg.clientId,
                 "access_type"   => "offline",
                 "scope"         => join(cnfg.scopes, " "),
                 "prompt"        => "select_account",
                 "response_type" => "code")
   return URI(URI(AUTH_ENDPOINT); query=params) |> string
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
   @info "Authentication Url: $(url)"
   escUrl = Utils.escapeAmpersand(url)
   DefaultApplication.open(escUrl; wait=true)
   code = await_authorization_code(cnfg.redirectUrl)
   @info "Authorization Code: $(code)"
   return code
end

function get_tokens(cnfg::Data.Config, code::String)::Data.Tokens
   body = Dict("code"          => code,
               "redirect_uri"  => cnfg.redirectUrl,
               "client_id"     => cnfg.clientId,
               "client_secret" => cnfg.clientSecret,
               "scope"         => join(cnfg.scopes, " "),
               "grant_type"    => "authorization_code")
   hdrs = ["Content-Type" => "application/x-www-form-urlencoded"]
   resp = HTTP.post(TOKEN_ENDPOINT, hdrs, URIs.escapeuri(body))
   json = resp.body |> String
   atkn = Tokens.read(json) 
   atkn.expires_in = Utils.timeInMS() + atkn.expires_in
   rtkn = JSON3.read(json).refresh_token
   return (rtkn, atkn)
end

function renew_access_token(cnfg::Data.Config, refreshToken::String)::Data.AccessToken
   body = Dict("client_id"     => cnfg.clientId,
               "client_secret" => cnfg.clientSecret,
               "refresh_token" => refreshToken,
               "grant_type"    => "refresh_token")
   hdrs = ["Content-Type" => "application/x-www-form-urlencoded"]
   resp = HTTP.post(TOKEN_ENDPOINT, hdrs, URIs.escapeuri(body))
   atkn = resp.body |> String |> Tokens.read
   atkn.expires_in = Utils.timeInMS() + atkn.expires_in
   return atkn
end

function request(method, url, body, params)
   hdrs = ["Authorization" => "$(atkn[].token_type) $(atkn[].access_token)",
           "Accept"        => "application/json"]
   resp = HTTP.request(method, url, hdrs, JSON3.write(body); query=params)
   return resp.body |> String |> JSON3.read
end

# It checks fPath for old refresh tokn, if available, it generate new access token and 
# returns it, otherwise, it generates new access_token and refresh_token via oauth2 
function get_tokens(fPath::String, cnfg::Data.Config)::Data.Tokens
   try
      rtkn = Tokens.read_from_file(fPath)
      atkn = renew_access_token(cnfg, rtkn)
      (rtkn, atkn)
   catch e
      @error e
      code = OAuth2.get_authorization_code(cnfg)
      (rtkn, atkn) = OAuth2.get_tokens(cnfg, code)
      Tokens.save_to_file(fPath, rtkn)
      return (rtkn, atkn)
   end
end

end