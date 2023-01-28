local Route = require "luxure.route"
local Error = require "luxure.error"
---@class Router
---
---The decision maker that pairs in incoming request with a registered
---handler
---@field public routes table List of Routes registered
local Router = {}

Router.__index = Router

function Router.new()
  local base = {routes = {}}
  setmetatable(base, Router)
  return base
end
---Dispatch a request to the approparte Route
---@param req Request
---@param res Response
function Router:route(req, res)
  for _, route in pairs(self.routes) do
    local matched, params = route:matches(req.url)
    if matched and route:handles_method(req.method) then
      req.params = params
      local handled, err = Error.pcall(route.handle, route, req, res)
      if not handled and err then res:set_status(err.status or 500) end
      req.err = err
      req.handled = handled
    end
  end
end
---Register a single route
---@param path string The route for this request
---@param method string the HTTP method for this request
---@param callback fun(req:Request, res:Response)
---The callback this route will use to handle requests
function Router:register_handler(path, method, callback)
  if self.routes[path] == nil then self.routes[path] = Route.new(path) end
  self.routes[path].methods[method] = callback
end

return Router
