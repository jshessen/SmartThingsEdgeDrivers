---@class Error
---
---Represents and error in the request/response cycle
---@field public msg string The original error message
---@field public msg_with_line string The original error message with the file/line number
---@field public status number The http status code to use for this response defaults to 500
---@field public traceback string The stacktrace for this error
local Error = {
  __tostring = function(err)
    local ret = err.msg_with_line or err.msg or "Unknown Error"
    if err.traceback ~= nil then
      ret = ret .. string.format("\n%s", err.traceback)
    end
    return ret
  end,
}

Error.__index = Error

local function new_error(msg, msg_with_line, status, traceback)
  local ret = {
    msg = msg,
    msg_with_line = msg_with_line,
    status = status,
    traceback = traceback,
  }
  setmetatable(ret, Error)
  return ret
end

local function build_error_string(msg, status)
  if debug then
    local traceback = debug.traceback(msg, 3)
    local info = debug.getinfo(3)
    local orig_loc = string.format("%s:%s", info.short_src or "",
                                   info.currentline or "")
    msg = string.format("%s|%s|%s", msg, traceback, orig_loc)
  end
  return string.format("%s|%i", msg, status or 500)
end

---Wrapper around assert that coverts the
---message into an pipe sepereted list
---this format will be used by Error.pcall to reconstruct
---an Error if any calls to assert raise an error
---@param test boolean
---@param msg string
---@param status number defualts to 500
function Error.assert(test, msg, status)
  msg = build_error_string(msg or "assertion failed", status)
  return assert(test, msg)
end

---Raise and error with a message and status
---@param msg string
---@param status number
function Error.raise(msg, status) error(build_error_string(msg, status)) end
local function parse_error_msg(s)
  local i = 1
  local keys = {"msg", "traceback", "orig_loc", "status"}
  local values = {}
  for part in string.gmatch(s, "[^|]+") do
    local key = keys[i]
    if not key then
      i = 10
      break
    end
    values[key] = part
    i = i + 1
  end
  if i == 2 then
    values.status = values.traceback
    values.traceback = nil
    return values
  end
  if i ~= 5 then return s end
  return values
end

---Wrapper around `pcall` that will reconstruct the Error object
---on failure
---@return Error | string
function Error.pcall(...)
  local res = table.pack(pcall(...))
  local success = res[1]
  if not success then
    local parsed = parse_error_msg(res[2])
    if type(parsed) == "string" then return success, parsed end
    local stripped_message = string.gsub(parsed.msg,
                                         "^(.+luxure/error.lua:[0-9]+): ", "")
    local status = math.tointeger(parsed.status) or 500
    return false, new_error(stripped_message, string.format("%s %s",
                                                            parsed.orig_loc,
                                                            stripped_message),
                            status, parsed.traceback)
  end
  res.n = nil
  return success, table.unpack(res, 2)
end

return Error
