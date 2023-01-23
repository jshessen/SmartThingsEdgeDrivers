local buffer = require 'lifter_puller.buffer'
local puller = require 'lifter_puller.puller'
local event = require 'lifter_puller.event'

--- Iterator over all events in the xml
---@param text string The xml to parse
---@param is_frag boolean if the xml provided is a fragment
---@return function
local function events(text, is_frag)
    local p = puller.new(text, is_frag)
    return function ()
        local next = p:next()
        if next.ty == event.event_type.eof then
            return
        end
        return next
    end
end

return {
    Puller = puller,
    event_type = event.event_type,
    Event = event.Event,
    Buffer = buffer.Buffer,
    events = events,
}