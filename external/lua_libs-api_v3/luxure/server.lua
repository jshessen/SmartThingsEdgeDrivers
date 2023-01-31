local Router = require "luxure.router"
local lunch = require "luncheon"
local Request = lunch.Request
local Response = lunch.Response
local methods = require "luxure.methods"
local Error = require "luxure.error"
local cosock = require "cosock"
local log = require "log"

---@alias handler fun(req: Request, res: Response)

---@class Server
---
---The primary interface for working with this framework
---it can be used to register middleware and route handlers
---
---@field private sock table socket being used by the server
---@field public router Router The router for incoming requests
---@field private middleware table List of middleware callbacks
---@field public ip string defaults to '0.0.0.0'
---@field private env string defaults to 'production'
---@field private backlog number|nil defaults to nil
local Server = {}

Server.__index = Server

---@class Opts
---
---The options a server knows about
---@field public env string 'debug'|'production' if debug, more information is provided on errors
---@field public backlog number The number to pass to `socket:listen`
local Opts = {}
Opts.__index = Opts

---Create a new options object
---@param t table|nil If not the pre-set options
---@return Opts
function Opts.new(t)
  log.trace("Opts.new")
  t = t or {}
  return setmetatable({
    backlog = t.backlog,
    env = t.env or "production",
    sync = t.sync,
  }, Opts)
end

---Set the backlog property
---@param backlog number
---@return Opts
function Opts:set_backlog(backlog)
  log.trace("Opts:set_backlog", backlog)
  self.backlog = backlog
  return self
end

---Set the env property
---@param env string 'production'|'debug' The env string
---@return Opts
function Opts:set_env(env)
  log.trace("Opts:set_env", env)
  self.env = env
  return self
end

---Constructor for a Server that will use luasocket's socket
---implementation
---@param opts Opts The configuration of this Server
function Server.new(opts)
  log.trace("Server.new")
  local sock = cosock.socket.tcp()
  return Server.new_with(sock, opts)
end

---Constructor for a Server that will use the provided socket
---The socket provided must have a similar api to the luasocket's tcp socket and
---also be compatible with cosock
---@param sock table The socket to use
---@param opts Opts The configuration of this Server
function Server.new_with(sock, opts)
  log.trace("Server.new_with")
  opts = opts or Opts.new()
  local base = {
    sock = sock,
    ---@type Router
    router = Router.new(),
    ---@type fun(req:Request,res:Response)
    middleware = nil,
    ---@type string
    ip = "0.0.0.0",
    ---@type string
    env = opts.env or "production",
    ---@type number
    backlog = opts.backlog,
    _sync = opts.sync,
  }
  return setmetatable(base, Server)
end

---Override the default IP address
---@param ip string
---@return Server
function Server:set_ip(ip)
  log.trace("Server:set_ip", ip)
  self.ip = ip
  return self
end

---Attempt to open a socket
---@param port number|nil If provided, the port this server will attempt to bind on
---@return Server
function Server:listen(port)
  log.trace("Server:listen", port)
  if port == nil then port = 0 end
  assert(self.sock:bind(self.ip, port or 0))
  self.sock:listen(self.backlog)
  local ip, resolved_port = self.sock:getsockname()
  self.ip = ip
  self.port = resolved_port
  return self
end

---Register some middleware to be use for each request
---@param middleware fun(req:Request, res:Response, next:fun(res:Request, res:Response))
---@return Server
function Server:use(middleware)
  log.trace("Server:use")
  if self.middleware == nil then
    ---@type fun(req:Request,res:Response)
    self.middleware = function(req, res)
      self.router.route(self.router, req, res)
    end
  end
  local next = self.middleware
  self.middleware = function(req, res)
    local success, err = Error.pcall(middleware, req, res, next)
    if not success then
      req.err = req.err or err
      res:set_status(err.status)
    end
  end
  return self
end

---Route a request, first through any registered middleware
---followed by any registered handler
---@param req Request
---@param res Response
function Server:route(req, res)
  log.trace("Server:route")
  if self.middleware then
    self.middleware(req, res)
  else
    self.router:route(req, res)
  end
end

---generate html for error when in debug mode
---@param err Error
local function debug_error_body(err)
  log.trace("debug_error_body")
  local code = err.status or "500"
  local h2 = err.msg_with_line or "Unknown Error"
  local pre = err.traceback or ""
  return string.format([[<!DOCTYPE html>
<html>
    <head>
    </head>
    <body>
        <h1>Error processing request: <code> %s </code></h1>
        <h2>%s</h2>
        <pre>%s</pre>
    </body>
</html>
    ]], code, h2, pre)
end

local function error_request(env, err, res)
  log.trace("error_request")
  if res:has_sent() then
    log.warn("error sending after bytes have been sent...")
    log.warn(err)
    return
  end
  if env == "production" then
    res:send(err.msg or "")
    return
  end
  res:set_content_type("text/html"):send(debug_error_body(err))
  return
end

function Server:_tick(incoming)
  log.trace("Server:_tick")
  local req, req_err = Request.tcp_source(incoming)
  if req_err then
    incoming:close()
    return nil, req_err
  end
  local res = Response.new(200, incoming)
  self:route(req, res)
  local has_sent = res:has_sent()
  if req.err then
    error_request(self.env, req.err, res)
  elseif not req.handled then
    if not has_sent then res:set_status(404):send("") end
  end
  if not res.hold_open then incoming:close() end
  return 1
end

---A single step in the Server run loop
---which will call `accept` on the underlying socket
---and when that returns a client socket, it will
---attempt to route the Request/Response objects through
---the registered middleware and routes
function Server:tick(err_callback)
  log.trace("Server:tick")
  local incoming, err = self.sock:accept()
  if not incoming then
    err_callback(err)
    return
  end
  if not self._sync then
    cosock.spawn(function()
      local nopanic, success, err = pcall(self._tick, self, incoming)
      if not nopanic then
        err_callback(success)
        return
      end
      if not success then err_callback(err) end
    end, string.format("Accepted request (ptr: %s)", incoming))
  else
    local nopanic, success, err = pcall(self._tick, self, incoming)
    if not nopanic then
      err_callback(success)
      return
    end
    if not success then err_callback(err) end
  end
end

function Server:_run(err_callback, should_continue)
  should_continue = should_continue or function() return true end
  log.trace("Server:_run")
  while should_continue() do self:tick(err_callback) end
end

---Start this server, blocking forever
---@param err_callback fun(msg:string):boolean Optional callback to be run if `tick` returns an error
function Server:run(err_callback, should_continue)
  log.trace("Server:run")
  err_callback = err_callback or function() return true end
  if not self._sync then
    cosock.spawn(function() self:_run(err_callback, should_continue) end,
                 "luxure-main-loop")
    cosock.run()
  else
    self:_run(err_callback, should_continue)
  end
end

for _, method in ipairs(methods) do
  local subbed = string.lower(string.gsub(method, "-", "_"))
  Server[subbed] = function(self, path, callback)
    log.trace(string.format("Server:%s", subbed))
    self.router:register_handler(path, method, callback)
    return self
  end
end

return {Server = Server, Opts = Opts}
