--- Event Type "enum"
local event_type = {
    declaration = 'Declaration',
    open_tag = 'OpenTag',
    close_tag = 'CloseTag',
    tag_end = 'TagEnd',
    attribute = 'Attribute',
    c_data = 'CData',
    comment = 'Comment',
    processing_instruction = 'ProcessingInstruction',
    doctype_start = 'DocTypeStart',
    doctype = 'DocType',
    entity_declaration = 'EntityDeclaration',
    doctype_end = 'DocTypeEnd',
    cdata = "CData",
    text = "Text",
    eof = "EOF",
}

---@class Event
---@field public ty string
---@field public prefix string|nil
---@field public name string|nil
---@field public version string|nil
---@field public encoding string|nil
---@field public standalone boolean|nil
---@field public target string|nil
---@field public content string|nil
---@field public text string|nil
---@field public external_id string|nil
---@field public external_value string[2]|string|nil
---@field public ndata string|nil
---@field public value string|nil
---@field public is_empty boolean|nil
local Event = {}

Event.__index = Event

---
---@param e table
---@return Event
local function _create(e)
    setmetatable(e, Event)
    return e
end

---ctor for Declaration
---@param version string
---@param encoding string
---@param standalone boolean
---@return Event
function Event.decl(version, encoding, standalone)
    return _create{
        ty = event_type.declaration,
        version = version,
        encoding = encoding,
        standalone = standalone,
    }
end

---ctor for processing instruction
---@param target string
---@param content string
---@return Event
function Event.pi(target, content)
    return _create{
        ty = event_type.processing_instruction,
        target = target,
        content = content,
    }
end

---ctor for comment
---@param text string
---@return Event
function Event.comment(text)
    return _create{
        ty = event_type.comment,
        text = text,
    }
end

---ctor for doctype start
---@param name string
---@param external_id string
---@param external_value string[] 1-2 entry list table
---@return Event
function Event.doctype_start(name, external_id, external_value)
    return _create{
        ty = event_type.doctype_start,
        name = name,
        external_id = external_id,
        external_value = external_value,
    }
end

---ctor for empty doctype
---@param name string
---@param external_id string
---@param external_value string[]
---@return Event
function Event.empty_doctype(name, external_id, external_value)
    return _create{
        ty = event_type.doctype,
        name = name,
        external_id = external_id,
        external_value = external_value,
    }
end

---ctor for entity declaration
---@param name string
---@param external_id string
---@param external_value string[]
---@param ndata string
---@return Event
function Event.entity_declaration(name, external_id, external_value, ndata)
    return _create{
        ty = event_type.entity_declaration,
        name = name,
        external_id = external_id,
        external_value = external_value,
        ndata = ndata,
    }
end

---ctor for DocTypeEnd
---@return Event
function Event.doctype_end()
    return _create{
        ty = event_type.doctype_end
    }
end

---<name
---<prefix:name
---@param prefix string
---@param name string
---@return Event
function Event.open_tag(prefix, name)
    return _create{
        ty = event_type.open_tag,
        prefix = prefix,
        name = name,
    }
end

--- attr="value"
--- prefix:attr="value"
---@param prefix string
---@param name string
---@param value string
---@return Event
function Event.attr(prefix, name, value)
    return  _create{
        ty = event_type.attribute,
        prefix = prefix,
        name = name,
        value = value
    }
end

--- </name>
---@param prefix string
---@param name string
---@return Event
function Event.close_tag(prefix, name)
    return _create{
        ty = event_type.close_tag,
        prefix = prefix,
        name = name,
    }
end

--- >
--- /> (empty)
---@param is_empty boolean
---@return Event
function Event.tag_end(is_empty)
    return _create{
        ty = event_type.tag_end,
        is_empty = is_empty,
    }
end

---<![CDATA[text]]>
---@param text string
---@return Event
function Event.cdata(text)
    return _create{
        ty = event_type.cdata,
        text = text,
    }
end

--->text</
---@param text string
---@return Event
function Event.text(text)
    return _create{
        ty = event_type.text,
        text = text
    }
end

---End of stream reached
---@return Event
function Event.eof()
    return _create{ ty = event_type.eof }

end

return {
    Event = Event,
    event_type = event_type,
}
