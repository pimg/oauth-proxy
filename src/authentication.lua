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
  local res, err = httpc:request_uri("http://127.0.0.1:9999/token", {
        method = "POST",
        body = "grant_type=client_credentials&scope=&client_id=569fcd05&client_secret=237b44d4a646f36410ca4313e8e8a877",
        headers = {
          ["Content-Type"] = "application/x-www-form-urlencoded",
        }
      })

      if not res then
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
    token = get_token()
    access_token = token.access_token
    expiration = token.expires_in
    ngx.log(ngx.NOTICE, "expires_in " .. expiration)
    cache:set("token", access_token, expiration)
  end

  return access_token
end

return _M