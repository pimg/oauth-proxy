local _M = {}
local lrucache = require("resty.lrucache")
local http = require "resty.http"
local cjson = require "cjson"
local httpc = http.new()

local cache, err = lrucache.new(20)  
if not cache then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local function get_token()
  local token_url = ngx.var.authorization_url
  local client_id = ngx.var.client_id
  local client_secret = ngx.var.client_secret
  local request_body = string.format( "grant_type=client_credentials&scope=&client_id=%s&client_secret=%s", client_id, client_secret )
  local res, err = httpc:request_uri(token_url, {
        method = "POST",
        body = request_body,
        headers = {
          ["Content-Type"] = "application/x-www-form-urlencoded",
        }
      })

  if res == nil then
    ngx.log(ngx.ERR, "failed to request: ".. err)
    return
  end

  local token_json = res.body
  local token_tbl = cjson.decode(token_json)

  return token_tbl
end

function _M.authenticate()

  local access_token = cache:get("token")
  if access_token == nil then
    local token = get_token()
    if not token then
      ngx.status = 500
      return "token could not be retrieved"
    end
    access_token = token.access_token
    local expiration = token.expires_in
    ngx.log(ngx.NOTICE, "expires_in " .. expiration)
    cache:set("token", access_token, expiration)
  end
  ngx.req.set_header("Authorization", "Bearer " .. access_token)
  return access_token
end

return _M