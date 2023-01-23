local net_url = require "net.url"
local Error = require "luxure.error"

---@class Route
---
---A single instance of a route
---@field public path string raw string that comprises this path
---@field public segments table list of ids or path segments, each segment may be a parameter if preceded by a :
---@field public vars table list of variables that will be parsed from the segments field
---@field public methods table list of callbacks registered to a method/path pair
local Route = {}

Route.__index = Route

---construct a new Route parsing any route parameters in the process
---@param path string
function Route.new(path)
  local url = net_url.parse(path)
  url.segments = {}
  url.methods = {}
  local i = 1
  for part in string.gmatch(url.path, "[^/]+") do
    local val = {id = part, is_var = false}
    -- luacheck: ignore _s _e
    local _s, _e, var = string.find(part, "^:(.+)")
    if var ~= nil then
      val.id = var
      val.is_var = true
    end
    table.insert(url.segments, val)
    i = i + 1
  end
  setmetatable(url, Route)
  return url
end

function Route:handles_method(method) return self.methods[method] ~= nil end

---Check if a parsed url matches this route
---@param url table the parsed table representing this url
function Route:matches(url)
  local params = {}
  local i = 0
  local path = url.path
  if string.find(url.path, "/$") then path = string.sub(path, 1, -2) end
  for part in string.gmatch(path, "[^/]+") do
    i = i + 1
    local segment = self.segments[i]
    if segment == nil then return false end
    if segment.is_var then
      params[segment.id] = part
    elseif segment.id ~= part then
      return false
    end
  end
  return #self.segments == i, params
end

---The request/response handler for this route
---@param req Request the incoming request
---@param res Response the outgoing response
function Route:handle(req, res)
  Error.assert(self.methods[req.method],
               "attempt to dispatch an unhandled method")
  self.methods[req.method](req, res)
end

return Route
