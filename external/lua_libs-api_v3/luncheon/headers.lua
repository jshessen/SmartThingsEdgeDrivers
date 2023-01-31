---@class Headers
---
---A map of the key value pairs from the header portion
---of an HTTP request or response. The fields listed below
---are some common headers but the list is not exhaustive.
---
---When each header is serialized, it is added as a property with
---lower_snake_case. For example, `X-Forwarded-For` becomes `x_forwarded_for`.
---
---Typically each header's value will be a string, however if there are multiple entries
---for any header, it will be a table of strings.
---
---@field private _inner table A table containing the deserialized header key/value pairs
---@field private _last_key string The last key deserialized, for multiline headers
local Headers = {}

Headers.__index = Headers

local function _append(t, key, value)
    value = tostring(value)
    if not t[key] then
        t[key] = value
    elseif type(t[key]) == 'string' then
        t[key] = {t[key], value}
    else
        table.insert(t[key], value)
    end
end

---Serialize a key value pair
---@param key string
---@param value string
---@return string
function Headers.serialize_header(key, value)
    if type(value) == 'table' then
        value = value[#value]
    end
    -- special case for MD5
    key = string.gsub(key, 'md5', 'mD5')
    -- special case for ETag
    key = string.gsub(key, 'etag', 'ETag')
    if #key < 3 then
        return string.format('%s: %s', key:upper(), value)
    end
    -- special case for WWW-*
    key = string.gsub(key, 'www', 'WWW')
    local replaced = key:sub(1, 1):upper() .. string.gsub(key:sub(2), '_(%l)', function (c)
        return '-' .. c:upper()
    end)
    return string.format('%s: %s', replaced, value)
end

---Serialize the whole set of headers separating them with a '\\r\\n'
---@return string
function Headers:serialize()
    local ret = ''
    for header in self:iter() do
        ret = ret .. header .. '\r\n'
    end
    return ret
end

---Append a chunk of headers to this map
---@param text string
function Headers:append_chunk(text)
    if text == nil then
        return nil, 'nil header'
    end
    if string.match(text, '^%s+') ~= nil then
        if not self._last_key then
            return nil, 'Header continuation with no key'
        end
        local existing = self:get_one(self._last_key)
        self._inner[self._last_key] = string.format('%s %s', existing, text)
        return 1
    end
    for raw_key, value in string.gmatch(text, '([^%c()<>@,;:\\"/%[%]?={} \t]+): (.+);?') do
        self:append(raw_key, value)
    end
    return 1
end

---Constructor for a Headers instance with the provided text
---@param text string
---@return Headers
function Headers.from_chunk(text)
    local headers = Headers.new()
    headers:append_chunk(text)
    return headers
end

---Bare constructor
function Headers.new()
    local ret = {
        _inner = {},
        last_key = nil,
    }
    setmetatable(ret, Headers)
    return ret
end

---Convert a standard header key to the normalized
---lua identifer used by this collection
---@param key string
---@return string
function Headers.normalize_key(key)
    local lower = string.lower(key)
    local normalized = string.gsub(lower, '-', '_')
    return normalized
end

---Insert a single key value pair to the collection
---@param key string
---@param value string
---@return Headers
function Headers:append(key, value)
    key = Headers.normalize_key(key)
    _append(self._inner, key, value)
    self._last_key = key
    return self
end

---Get a header from the map of headers
---
---This will first normalize the provided key. For example
---'Content-Type' will be normalized to `content_type`.
---If more than one value is provided for that header, the
---last value will be provided
---@param key string
---@return string
function Headers:get_one(key)
    local k = Headers.normalize_key(key or '')
    local value = self._inner[k]
    if type(value) == 'table' then
        return value[#value]
    else
        return value
    end
end

---Get a header from the map of headers as a list of strings.
---In the event that a header's key is duplicated, the value
---is stored internally as a list of values. This method is
---useful for getting that list.
---
---
---This will first normalize the provided key. For example
---'Content-Type' will be normalized to `content_type`.
---@param key string
---@return string[]
function Headers:get_all(key)
    local k = Headers.normalize_key(key or '')
    local values = self._inner[k]
    if type(values) == 'string' then
        return {values}
    end
    return values
end

---Return a lua iterator over the key/value pairs in this header map
function Headers:iter()
    local last = nil
    return function ()
        local k, v = next(self._inner, last)
        last = k
        if not k then
            return
        end
        return Headers.serialize_header(k, v)
    end
end

return Headers
