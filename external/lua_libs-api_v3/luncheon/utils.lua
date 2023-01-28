---@module utils
---
---Utilities that don't fall under a specific class
---
local m = {}

local socket_wrapper = {}
socket_wrapper.__index = socket_wrapper

---Attempt to call the `send` method on the provided, `sock` retrying on failure or timeout
---@param sock luasocket.socket The socket to send on
---@param s string The string to send
---@return integer|nil @the number of bytes sent if not `nil`
---@return nil|string @the last error message encountered if not `nil`
function m.send_all(sock, s)
    local total_sent = 0
    local target = #s
    local retries = 0
    while total_sent < target and retries < 5 do
        local res = table.pack(pcall(sock.send, sock, string.sub(s, total_sent)))
        if not res[1] then
            retries = retries + 1
        else
            local sent, err = res[2], res[3]
            if not sent then
                if err == 'closed' then
                    return nil, 'Attempt to send on closed socket'
                elseif err == 'timeout' then
                    retries = retries + 1
                    if retries == 5 then
                        return nil, err
                    end
                else
                    return nil, err, total_sent
                end
            else
                total_sent = total_sent + sent
            end
        end
    end
    return total_sent
end

---Use a luasocket api conforming table as a source via the ltn12 api
---the function returned will attempt to call the `receive` method on the provided `socket`
---@param socket luasocket.tcp A tcp socket
---@return fun(pat:string|integer|nil):string,string
function m.tcp_socket_source(socket)
    return function(pat)
        if pat == 0 then
            return ''
        end
        if pat == nil then
            pat = '*l'
        end
        return socket:receive(pat)
    end
end

---Get the first line from a chunk, discarding the new line characters, returning
---the line followed by the remainder of the chunk after that line
---@param chunk string
---@return string @If not nil, the line found, if nil no new line character was found
---@return string
function m.next_line(chunk, include_nl)
    local _, e, line = string.find(chunk, '^([^\n]+\n)')
    if not line then
        return nil, chunk
    end
    local ret = line
    local rem = string.sub(chunk, e+1)
    if include_nl then
        return ret, rem
    end
    return string.gsub(line, '[\r\n]', ''), rem
end

---Get the first line from a chunk, discarding the new line characters, returning
---the line followed by the remainder of the chunk after that line
---@param chunk string
---@return string @If not nil, the line found, if nil no new line character was found
---@return string
function m.extract_len(chunk, len)
    local ret = string.sub(chunk, 1, len)
    local rem = ''
    if #chunk > len then
        rem = string.sub(chunk, len+1)
    end
    return ret, rem
end

---wrap a luasocket udp socket in an ltn12 source function, this will handle finding new line
---characters. This will call `receive` on the provided `socket` repeatedly until a new line is found
---@param socket luasocket.udp
---@return function():string,string
function m.udp_socket_source(socket)
    local buffer = ''
    -- If this source is called with a length argument,
    -- we have 
    local function with_length(len)
        local chunk = nil
        local target_length = len - #buffer
        while target_length > 0 do
            local bytes, err = socket:receive(target_length)
            if not bytes then
                return nil, err
            end
            target_length = target_length - #bytes
            buffer = buffer .. bytes
        end
        chunk, buffer = m.extract_len(buffer, len)
        return chunk
    end
    local function next_line()
        local chunk = nil
        if #buffer > 0 then
            chunk, buffer = m.next_line(buffer)
            if chunk then
                return chunk
            end
        end
        while true do
            local bytes, err = socket:receive()
            if bytes == nil then
                return nil, err
            end
            chunk, buffer = m.next_line(buffer .. bytes)
            if chunk then
                return chunk
            end
        end
    end
    return function(len)
        if len then
            return with_length(len)
        end
        return next_line()
    end
end

return m