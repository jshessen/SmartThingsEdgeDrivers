local json = require "st.json"
local datastore = _envlibrequire "datastore"

--- @module st_datastore
local st_datastore = {}

-- A registry of metatables we have created for datastore entries.  This allows us to
-- know when a value passed in actually has one of our mts
local our_mts = {}

-- Set up our mt registry with weak keys, so they will collected if this is the last reference
local mt_mt = {}
setmetatable(our_mts, mt_mt)
mt_mt.__mode = "k"

local convert_child

-- Recursively check keys and values to verify that they will be serializable
-- Raises error if any value is invalid
local function check_if_valid(value)
    local t = type(value)
    local valid_types = {
        boolean = true,
        number = true,
        string = true,
        ["nil"] = true,
    }

    if t == "table" then
        local table_mt = getmetatable(value)
        -- Only allow a table with metatable behavior if it is a datastore table
        if table_mt ~= nil and not our_mts[table_mt] then
            error("datastore table values should be simple and not include metatable functionality", 2)
        end
        for k,v in pairs(value) do
            check_if_valid(k)
            check_if_valid(v)
        end
        -- all keys and values are of accepted types.
        return
    elseif valid_types[t] then
        return
    end
    error("Data store keys and values must be JSON encodable: " .. tostring(value) .. " is of unsupported type " .. type(value), 2)
end

-- Create a new metatable to control the behavior of a datastore or a nested table
-- within that datastore.  The metatable constrains values to be serializable so
-- that we can pass it over RPC.  It also tracks the dirty status so if any nested
-- value is changed the top level datastore will have :is_dirty() return true
local function new_mt(parent)
    local mt = {}
    our_mts[mt] = true

    mt.__values = {}
    mt.__funcs = {}
    mt.__parent = parent

    -- Set up controls to ensure any value written to the data store is json encodable
    mt.__newindex = function(self, key, value)
        if mt.__funcs[key] ~= nil then
            error("Key: " .. key .. " refers to a protected method, do not overwrite.", 2)
        end
        -- will raise error if invalid
        check_if_valid(key)
        check_if_valid(value)

        -- only able to set here if it was valid
        mt.__values[key] = convert_child(value, mt)
        mt:__set_dirty()
    end
    mt.__set_dirty = function(my_mt)
        if my_mt.__parent ~= nil then
            my_mt.__parent:__set_dirty()
        else
            my_mt.__dirty = true
        end
    end
    mt.__index = function(self, key)
        return mt.__funcs[key] or mt.__values[key]
    end
    mt.__pairs = function(self)
        return pairs(mt.__values)
    end

    -- Define any functionality on the data store we want
    if parent == nil then
        function mt.__funcs:load()
            local loaded_json = datastore.get()
            -- the emptry string is not valid JSON.
            -- dkjson for whatever reason handled this gracefully,
            -- but serde will throw an error. We guard against this
            -- now.
            if (loaded_json == nil) or #loaded_json == 0 then return end
            -- TODO: error handling?
            local loaded_table, _ = json.decode(loaded_json)
            if type(loaded_table) == "table" then
                for k, v in pairs(loaded_table) do
                    mt.__values[k] = convert_child(v, mt)
                end
            end
        end

        function mt.__funcs:save()
            -- Shouldn't fail as we have ensured that all values are encodable, but could fail if
            -- users bypassed restrictions
            local succ, val = pcall(json.encode, self:get_serializable())
            if succ then
                datastore.set(val)
                mt.__dirty = false
            else
                error("Unable to serialize datastore value: " .. val, 2)
            end
        end
    end

    --- @function st_datastore:is_dirty()
    --- A function to return the dirty status of the datastore
    --- @return boolean the dirty status of the datastore
    function mt.__funcs:is_dirty()
        if mt.__parent == nil then
            return mt.__dirty
        else
            mt.__parent.__funcs.is_dirty(mt.__parent)
        end
    end

    local function get_serializable()
        local out_table = {}
        for k,v in pairs(mt.__values) do
            if type(v) == "table" then
                out_table[k] = v:get_serializable()
            else
                out_table[k] = v
            end
        end
        return out_table
    end
    --- @function st_datastore.getserializable()
    --- A function to return the serialable version of the table
    ---
    --- This primarily will pull out just the values and return the value table without
    --- metatables and functions included
    ---
    --- @return table a table with the values to be serialized
    mt.__funcs.get_serializable = get_serializable

    return mt
end

-- This is a local recursive function to convert each value present in a table being set
-- in the data store to be able to use the above defined metatable.
function convert_child(child, parent_mt)
    if type(child) ~= "table" then
        return child
    else
        local child_mt = new_mt(parent_mt)
        for k,v in pairs(child) do
            child_mt.__values[k] = convert_child(v, child_mt)
            child[k] = nil
        end
        setmetatable(child, child_mt)
        return child
    end
end

--- Initialize the datastore for this driver
---
--- This will create and return a special lua table which, when written to
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @return table The table to write values that need to be persisted to.
function st_datastore.init(driver)
    local ds = {}
    setmetatable(ds, new_mt())
    ds.load()
    return ds
end

return st_datastore
