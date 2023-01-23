
--- binary 0011 1111 which represents the utf-8 continue mask
local CONT_MASK = 63

local Buffer = {}

Buffer.__index = Buffer

function Buffer.new(s)
    local ret = {
        stream = s,
        current_idx = 1,
        len = #s,
    }
    setmetatable(ret,  Buffer)
    return ret
end

---Check if the buffer has reached the last character
function Buffer:at_end()
    return self.current_idx >= self.len
end

function Buffer:current_char()
    return string.sub(self.stream, self.current_idx, self.current_idx)
end

---Get the current byte
function Buffer:current_byte()
    return string.byte(self.stream, self.current_idx, self.current_idx)
end

---Get the next byte, with no regard for any string encoding
---returns nil,string if idx is past the end of the buffer
---@return number|nil, string|nil
function Buffer:next_byte()
    local idx = self.current_idx + 1
    if idx >= self.len then
        return nil, 'At EOF'
    end
    return string.byte(self.stream, idx, idx)
end

---Move the buffer forward a number of bytes, returning the substring
---that was just passed. Returns nil, string ct would move past the end of the buffer
---@param ct number The number of bytes to move forward
---@return string|nil,string|nil
function Buffer:advance(ct)
    local new_idx = self.current_idx + ct
    if new_idx > self.len then
        return nil, 'Would pass EOF'
    end
    local s
    s = string.sub(self.stream, self.current_idx, new_idx-1)
    -- if ct == 1 then
    --     s = string.sub(self.stream, self.current_idx, self.current_idx)
    -- else
    -- end
    self.current_idx = new_idx
    return s
end

---Check if the buffer currently starts with the provided string
---@param s string The string to match
---@return boolean
function Buffer:starts_with(s)
    local sub = string.sub(self.stream, self.current_idx)
    local start, _stop = string.find(
        sub,
        string.format('^%s', s)
    )
    return start ~= nil
end


function Buffer:at_cdata_start()
    local slice = string.sub(
        self.stream,
        self.current_idx,
        self.current_idx + #'<![CDATA')
    return 
        slice == '<![CDATA['
end
---Consume the provided string, if the buffer isn't at
---the current string will return nil, string
---@param s string The string to match
---@return string|nil,string|nil
function Buffer:consume_str(s)
    local s2 = string.match(self.stream, string.format('^%s', s), self.current_idx)
    if not s2 or s2 == '' then
        return nil, string.format('mismatched consume: "%s" vs "%s"', s, s2)
    end
    self:advance(#s2)
    return s2
end

--- Consume bytes while the closure returns true
---@param f fun(b:string):boolean
---@return string|nil,string|nil
function Buffer:consume_while(f)
    local pos = self.current_idx
    while not self:at_end() do
        local slice = string.sub(self.stream, pos, pos)
        if f(slice) then
            pos = pos + 1
        else
            local ret = string.sub(self.stream, self.current_idx, pos - 1)
            self:advance(pos - self.current_idx)
            return ret
        end
    end
end


function Buffer:consume_until(s)
    local slice = string.sub(self.stream, self.current_idx)

    local start, stop = string.find(slice, s)
    if start == nil then
        return nil, 'pattern not found'
    end
    local ret = string.sub(slice, 1, start-1)
    self.current_idx = self.current_idx + #ret
    return ret
end

--- Accumulate and mask the continue byte
---@param acc number The number to accumulate into
---@param b number The byte to accumulate
local function acc_cont_byte(acc, b)
    return (acc << 6) | (b & CONT_MASK)
end

--- Returns a utf-8 encoded
--- character as an up to 4 byte integer
function Buffer:next_utf8_int()
    local idx = self.current_idx
    local x = string.byte(self.stream, idx, idx) or 0
    if x < 128 then
        return x, 1
    end
    local len = 4
    if x < 0xE0 then -- 0xE0 == 1110 0000
        len = 2
    elseif x < 0xF0 then -- 0xF0 == 1111 0000
        len = 3
    end
    local y, z, w = string.byte(self.stream, idx + 2, idx + len + 2)
    local init = x & (0x7F >> 2)
    if len == 2 then
        return acc_cont_byte(init, y or 0), len
    end
    local y_z = acc_cont_byte(y & CONT_MASK, z or 0)
    if len == 3 then
        return (init << 12) | y_z, len
    end
    local y_z_w = acc_cont_byte(y_z, w or 0)
    return (init & 7) << 18 | y_z_w, len
end

function Buffer:skip_whitespace()
    local whitespace = string.match(self.stream, '^%s*', self.current_idx)
    self:advance(#whitespace)
    return #whitespace > 0
end

function Buffer:at_space()
    return string.find(self.stream, '^%s', self.current_idx) ~= nil
end

return Buffer
