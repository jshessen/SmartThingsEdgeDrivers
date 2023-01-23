local net_url = require 'net.url'
local Headers = require 'luncheon.headers'
local utils = require 'luncheon.utils'

---@class Request
---
---An HTTP Request
---
---@field public method string the HTTP method for this request
---@field public url table The parsed url of this request
---@field public http_version string The http version from the request first line
---@field public headers Headers The HTTP headers for this request
---@field public body string The contents of the request's body
---@field public socket table Lua socket for receiving/sending
---@field private _source fun():string ltn12 source
---@field private _parsed_headers boolean
---@field private _received_body boolean
local Request = {}
Request.__index = Request

--#region Parser

---Parse the first line of an HTTP request
---@param line string
---@return table
function Request._parse_preamble(line)
    local start, _, method, path, http_version = string.find(line, '([A-Z]+) (.+) HTTP/([0-9.]+)')
    if not start then
        return nil, string.format('Invalid http request first line: "%s"', line)
    end
    return {
        method = method,
        url = net_url.parse(path),
        http_version = http_version,
        body = nil,
        headers = nil,
    }
end

---Construct a request from a ltn12 source function
---@param source fun():string this should always return a single line when called
---@return Request
function Request.source(source)
    if not source then
        return nil, 'cannot create request with nil source'
    end
    local r = {
        _source = source,
        _parsed_headers = false,
    }
    setmetatable(r, Request)
    local line, acc_err = r:_next_line()
    if acc_err then
        return nil, acc_err
    end
    local pre, pre_err = Request._parse_preamble(line)
    if pre_err then
        return nil, pre_err
    end
    r.http_version = pre.http_version
    r.method = pre.method
    r.url = pre.url
    return r
end

---Create a new Request with a lua socket
---@param socket table tcp socket
---@return Request
function Request.tcp_source(socket)
    local utils = require 'luncheon.utils'
    local ret, err = Request.source(
        utils.tcp_socket_source(socket)
    )
    if not ret then
        return nil, err
    end
    ret.socket = socket
    return ret
end

---Create a new Request with a lua socket
---@param socket table udp socket
---@return Request, string|nil
function Request.udp_source(socket)
    local utils = require 'luncheon.utils'
    local ret, err =  Request.source(
        utils.udp_socket_source(socket)
    )
    if not ret then
        return nil, err
    end
    ret.socket = socket
    return ret
end

---Get the headers for this request
---parsing the incoming stream of headers
---if not already parsed
---@return Headers, string|nil
function Request:get_headers()
    if self._parsed_headers == false then
        local err = self:_fill_headers()
        if err ~= nil then
            return nil, err
        end
    end
    return self.headers
end

---read from the socket filling in the headers property
function Request:_fill_headers()
    while true do
        local done, err = self:_parse_header()
        if err ~= nil then
            return err
        end
        if done then
            self._parsed_headers = true
            return
        end
    end
end

---Read a single line from the socket and parse it as an http header
---returning true when the end of the http headers
---@return boolean|nil, string|nil
function Request:_parse_header()
    local line, err = self:_next_line()
    if err ~= nil then
        return nil, err
    end
    if self.headers == nil then
        self.headers = Headers.new()
    end
    if line == '' then
        return true
    else
        self.headers:append_chunk(line)
    end
    return false
end

---Read a single line from the socket
---@return string|nil, string|nil
function Request:_next_line()
    local line, err = self._source()
    return line, err
end

---Get the contents of this request's body
---if not yet received, this will read the body
---from the socket
---@return string|nil, string|nil
function Request:get_body()
    if not self._received_body then
        local err = self:_fill_body()
        if err ~= nil then
            return nil, err
        end
    end
    return self.body
end

---Read from the socket, filling the body property
---of this request
---@return string|nil
function Request:_fill_body()
    local len, err = self:content_length()
    if err ~= nil then
        return err
    end
    self.body = self._source(len or 0)
    self._received_body = true
end

---Get the value from the Content-Length header that should be present
---for all http requests
---@return number|nil, string|nil
function Request:content_length()
    local headers, err = self:get_headers()
    if not headers then
        return nil, err
    end
    local cl = headers:get_one('content_length')
    if cl == nil then
        return nil
    end
    local n = math.tointeger(cl)
    if not n then
        return nil, 'Invalid content length'
    end
    headers.content_length = n
    return n
end

--#endregion Parser

--#region Builder
---Construct a request Builder
---@param method string an http method string
---@param url string|table the path for this request as a string or as a net_url table
---@param socket table
---@return Request
function Request.new(method, url, socket)
    if type(url) == 'string' then
        url = net_url.parse(url)
    end
    return setmetatable({
        method = string.upper(method or 'GET'),
        url = url or net_url.parse('/'),
        headers = Headers.new({content_length = 0}),
        http_version = '1.1',
        body = '',
        socket = socket,
        _send_state = {
            stage = 'none',
        },
        _parsed_header = true
    }, Request)
end

---Add a header to the internal map of headers
---note: this is additive, so adding X-Forwarded-For twice will
---cause there to be multiple X-Forwarded-For entries in the serialized
---headers
---@param key string The Header's key
---@param value string The Header's value
---@return Request
function Request:add_header(key, value)
    self.headers:append(key, value)
    return self
end

---Set the Content-Type header for this request
---convenience wrapper around self:add_header('content_type', len)
---@param ct string The mime type to add as the Content-Type header's value
---@return Request
function Request:set_content_type(ct)
    self:add_header('content_type', ct)
    return self
end

---Set the Content-Length header for this request
---convenience wrapper around self:add_header('content_length', len)
---@param len number The Expected length of the body
---@return Request
function Request:set_content_length(len)
    self:add_header('content_length', len)
    return self
end

---append the provided chunk to this Request's body
---@param chunk string The text to add to this request's body
---@return Request
function Request:append_body(chunk)
    self.body = (self.body or '') .. chunk
    self:set_content_length(#self.body)
    return self
end

---Private method for serializing the url property into a valid URL string suitable
---for the first line of an HTTP request
---@return string
function Request:_serialize_path()
    if type(self.url) == 'string' then
        self.url = net_url.parse(self.url)
    end
    local path = self.url.path or '/'
    if not self.url.query or not next(self.url.query) then
        return path
    end
    return path .. '?' .. net_url.buildQuery(self.url.query)
end

---Private method for serializing the first line of the request
---@return string
function Request:_serialize_preamble()
    return string.format('%s %s HTTP/%s', string.upper(self.method), self:_serialize_path(), self.http_version)
end

---Serialize this request into a single string
---@return string
function Request:serialize()
    self:content_length(#self.body)
    local head = table.concat({
        self:_serialize_preamble(),
        self.headers:serialize(),
        ''
    }, '\r\n')
    return head .. self.body
end

---Serialize this request as a lua iterator that will
---provide the next line (including new line characters).
---This will split the body on any internal new lines as well
---@return fun():string
function Request:iter()
    local state = 'preamble'
    local last_header, value
    local body = self.body or ''
    return function()
        if state == 'preamble' then
            state = 'headers'
            local pre = self:_serialize_preamble()
            return pre .. '\r\n'
        end
        if state == 'headers' then
            last_header, value = next(self.headers._inner, last_header)
            if not last_header then
                state = 'body'
                return '\r\n'
            end
            return Headers.serialize_header(last_header, value) .. '\r\n'
        end
        if state == 'body' then
            value, body = utils.next_line(body, true)
            if not value then
                state = nil
                return body
            end
            return value
        end
    end
end

--#endregion Builder

--#region sink

---Serialize and pass the first line of this Request into the sink
---@return integer if not nil, success
---@return string if not nil and error message
function Request:send_preamble()
    if self._send_state.stage ~= 'none' then
        return 1 --already sent
    end
    local line = self:_serialize_preamble() .. '\r\n'
    local s, err = utils.send_all(self.socket, line)
    if not s then
        return nil, err
    end
    self._send_state.stage = 'header'
    return 1
end

---Pass a single header line into the sink functions
---@return integer|nil If not nil, then successfully "sent"
---@return string If not nil, the error message
function Request:send_header()
    if self._send_state.stage == 'none' then
        return self:send_preamble()
    end
    if self._send_state.stage == 'body' then
        return nil, 'cannot send headers after body'
    end
    local key, value = next(self.headers._inner, self._send_state.last_header)
    if not key then
        local s, e = utils.send_all(self.socket, '\r\n')
        if not s then
            return nil, e
        end
        self._send_state = {
            stage = 'body',
            sent = 0,
        }
        return 1
    end
    local line = Headers.serialize_header(key, value) .. '\r\n'
    local s, e = utils.send_all(self.socket, line)
    if not s then
        return nil, e
    end
    self._send_state.last_header = key
    return 1
end

---Slice a chunk of at most 1024 bytes from `self.body` and pass it to
---the sink
---@return integer|nil if not nil, success
---@return string if not nil and error message
function Request:send_body_chunk()
    if self._send_state.stage ~= 'body' then
        return self:send_header()
    end
    local start_idx = self._send_state.sent + 1
    local end_idx = start_idx + 1024
    local chunk = self.body:sub(start_idx, end_idx)
    local s, e = utils.send_all(self.socket, chunk)
    if not s then
        return nil, e
    end
    self._send_state.sent = self._send_state.sent + #chunk
    return 1
end

---Serialize and pass the request chunks into the sink
---@param bytes string|nil the final bytes to append to the body
---@return integer|nil If not nil sent successfully
---@return string if not nil the error message
function Request:send(bytes, skip_length)
    if bytes then
        self.body = self.body .. bytes
    end
    if self._send_state.stage ~= 'body' and not skip_length then
        self:set_content_length(#self.body)
    end
    while not self:_sending_body() or (self._send_state.sent or 0) < #self.body do
        local s, e = self:send_body_chunk()
        if not s then
            return nil, e
        end
    end
    return 1
end

function Request:_sending_body()
    return self._send_state.stage == 'body'
end

--#endregion

return Request
