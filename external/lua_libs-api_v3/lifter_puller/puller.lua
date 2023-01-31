local event = require 'lifter_puller.event'
local Buffer = require 'lifter_puller.buffer'


local Puller = {}


Puller.__index = Puller

local state = {
    declaration = 'Declaration',
    after_declaration = 'AfterDeclaration',
    doctype = 'Doctype',
    after_doctype = 'AfterDoctype',
    elements = 'Elements',
    attributes = 'Attributes',
    after_elements = 'AfterElements',
    done = 'End',
}

--- parse any number of letters, numbers, periods
--- underscores followed by a single `-` recursivly
function Puller:_parse_encoding_trailer()
    local s = self:eat('[a-zA-Z0-9._]*')
    local s2 = self:eat('-') or ''
    if not s or s == '' and not s2 then return '' end
    if not s2 then return s end
    if not s or s == '' then return s2 end
    return s .. s2 .. self:_parse_encoding_trailer()
end

function Puller:_parse_decl()
    self:_advancebuffer(6) -- <?xml
    self:_skip_whitespace()
    if not self:eat('version') then
        return nil, 'expected `version`'
    end
    if not self:eat('=') then
        return nil, 'expected = found ' .. string.char(self.buffer:current_byte())
    end
    local q = self:eat('\'') or self:eat('"')
    if not q then
        return nil, 'version must be quoted ' .. string.char(self.buffer:current_byte())
    end
    local v = self.buffer:consume_str('1%.%d+')
    if not v then
        return nil, 'expected version number'
    end
    self:eat(q)
    self:_skip_whitespace()
    local encoding
    if self:eat('encoding') then
        self:_parse_eq()
        local q2 = self:_parse_quote()
        local e
        encoding, e = self:eat('[a-zA-Z]')
        if not encoding then
            return nil, e
        end
        encoding = encoding .. self:_parse_encoding_trailer()
        self:_parse_quote(q2)
        self:_skip_whitespace()
    end
    local standalone
    if self:eat('standalone') then
        self:_parse_eq()
        local q3 = self:_parse_quote()
        if self:eat('yes') then
            standalone = true
        elseif self:eat('no') then
            standalone = false
        end
        if standalone == nil then
            return nil, 'Invalid value for standalone'
        end
        self:eat(q3)
    end
    self:_skip_whitespace()
    self:eat('%?>')
    return event.Event.decl(v, encoding, standalone)
end

function Puller:parse_doctype()
    self.buffer:advance(9)
    self:_skip_whitespace()
    local name, err = self:_eat_name()
    if not name then
        return nil, err
    end
    self:_skip_whitespace()
    local external_id, lit1, lit2
    if self.buffer:starts_with('SYSTEM') or self.buffer:starts_with('PUBLIC') then
        external_id, lit1, lit2 = self:parse_external_id()
    end
    self:_skip_whitespace()
    local current_char = self.buffer:current_char()
    if current_char ~= '>' and current_char ~= '[' then
        return nil, 'Expected > or [ in doctype found ' .. current_char
    end
    self.buffer:advance(1)
    local external_value = {}
    if not lit1 and not lit2 then
        external_value = nil
        external_value = {lit1, lit2}
    end
    if lit1 then table.insert(external_value, lit1) end
    if lit2 then table.insert(external_value, lit2) end
    if current_char == '[' then
        return event.Event.doctype_start(name, external_id, external_value)
    end
    return event.Event.empty_doctype(name, external_id, external_value)
end

function Puller:parse_comment()
    self.buffer:advance(4)
    local content = self.buffer:consume_until('-->')
    self.buffer:advance(3)
    return event.Event.comment(content)
end

function Puller:parse_pi()
    self.buffer:advance(2)
    local target, err = self:_eat_name()
    if not target then
        return nil, err
    end
    self:_skip_whitespace()
    local content = self.buffer:consume_until('?>')
    if content == '' then
        content = nil
    end
    self.buffer:advance(2)
    return event.Event.pi(target, content)
end

function Puller:parse_entity_decl()
    self:_advancebuffer(8) -- <!ENTITY
    self:_skip_whitespace()
    local is_ge = true
    if self.buffer:starts_with('%%') then
        self:_advancebuffer(1) -- %
        self:_skip_whitespace()
        is_ge = false
    end
    local name, err = self:_eat_name()
    if not name then
        return nil, err
    end
    self:_skip_whitespace()
    local def = self:parse_entity_def(is_ge)
    self:_skip_whitespace()
    if not self.buffer:starts_with('>') then
        return nil, string.format('expected > found %s', self.buffer:current_char())
    end
    self:_advancebuffer(1) -- >
    return event.Event.entity_declaration(name, def.ext_id, def.ext_val, def.ndata)
end

function Puller:parse_entity_def(is_ge)
    local c = self.buffer:current_char()
    if c == '"' or c == '\'' then
        self:_parse_quote(c)
        
        local contents = self.buffer:consume_while(function (ch) return ch ~= c end)
        self:_parse_quote(c)
        return {
            ext_val = contents,
        }
    elseif c == 'S' or c == 'P' then
        local id, lit1, lit2 = self:parse_external_id()
        
        if id == nil then
            return nil, lit1 --error here
        end
        local ret = {
            ext_id = id,
            ext_val = {lit1, lit2},
            ndata = nil,
        }
        if is_ge then
            self:_skip_whitespace()
            if self.buffer:starts_with("NDATA") then
                self:_advancebuffer(5) -- NDATA
                self:_skip_whitespace()
                local name, err = self:_eat_name()
                if not name then
                    return nil, err
                end
                ret.ndata = name
            end
        end
        return ret
    else
        return nil, string.format('Expected quote or SYSTEM or PUBLIC found "%s"', self.buffer:current_char())
    end
end

function Puller:parse_element_start()
    self.buffer:advance(1) -- <
    local prefix, name = self:_eat_qname()
    if prefix == nil then
        return nil, name --error here
    end
    if name == nil then
        return event.Event.open_tag(nil, prefix)
    end
    return event.Event.open_tag(prefix, name)
end

function Puller:parse_close_element()
    self:_advancebuffer(2) -- </
    local prefix, name = self:_eat_qname()
    if prefix == nil then
        return nil, name --error
    end
    self:_skip_whitespace()
    if not self:eat('>') then
        return nil, string.format('expected `>` found %s', self.buffer:current_char())
    end
    if name == nil then
        return event.Event.close_tag(nil, prefix)
    end
    return event.Event.close_tag(prefix, name)
end

function Puller:parse_attribute()
    local has_space = self.buffer:skip_whitespace()
    if self.buffer:starts_with('/>') then
        self:_advancebuffer(2) -- />
        return event.Event.tag_end(true)
    elseif self.buffer:starts_with('>') then
        self:_advancebuffer(1) -- >
        return event.Event.tag_end(false)
    end
    -- If we are not at the end of an open tag, we expected
    if not has_space then
        if self.buffer:at_end() then
            return nil, 'Unexpected EOF'
        else
            return nil, string.format('Expected space found `%s`', self.buffer:current_char())
        end
    end
    local prefix, name = self:_eat_qname()
    if prefix == nil then
        return nil, name --error here
    end
    local eq = self:eat('=')
    if eq == nil then
        return nil, string.format('expected = found %s', self.buffer:current_char())
    end
    local quote = self:_parse_quote()
    local value = self.buffer:consume_while(function (c) return c ~= quote and c ~= '<' end)
    if not self:_parse_quote(quote) then
        return nil, string.format('Invalid attribute value, expecting %s found %s', quote, self.buffer:current_char())
    end
    if name == nil then
        return event.Event.attr(
            nil, prefix, value
        )
    end
    return event.Event.attr(prefix, name, value)
end

function Puller:parse_text()
    local text, err = self.buffer:consume_until('<')
    if text == nil then
        return nil, err
    end
    if string.find(text, "]]>", nil, true) then
        return nil, 'Invalid text node, cannot contain `]]>`'
    end
    if string.find(text, '[^%s]') == nil then
        return self:next()
    end
    return event.Event.text(text)
end

function Puller:parse_cdata()
    self:_advancebuffer(9) --<![CDATA[
    local text = self.buffer:consume_until(']]>')
    self:_advancebuffer(3) --]]>
    return event.Event.cdata(text)
end

function Puller:parse_external_id()
    if not self.buffer:starts_with('SYSTEM') and not self.buffer:starts_with('PUBLIC') then
        return nil, 'Invalid external id, expected SYSTEM or PUBLIC'
    end
    local id = self.buffer:advance(6)
    self:_skip_whitespace()
    local q = self:_parse_quote()
    local lit1 = self.buffer:consume_while(function(s) return s ~= q end)
    self:_parse_quote(q)
    if id == 'SYSTEM' then
        return id, lit1
    else
        self:_skip_whitespace()
        local q2 = self:_parse_quote()
        local lit2 = self.buffer:consume_while(function(s) return s ~= q end)
        self:_parse_quote(q2)
        return id, lit1, lit2
    end
end

function Puller:_parse_quote(q)
    q = q or '["\']'
    local ret = self:eat(q)
    if ret == nil then
        return nil,  string.format('expected %s found: %s', q or '" or \'', self.buffer:current_char())
    end
    return ret
end

function Puller:_parse_eq()
    if not self:eat('=') then
        return false, string.format('expected equal sign found %s', self.buffer:current_char())
    end
    return true
end


function Puller:_eat_name()
    local at_start, len = self:_at_name_start()
    if not at_start then
        return nil, string.format('Invalid name start `%s`', string.sub(self.buffer.stream, self.buffer.current_idx))
    end
    local ret = self.buffer:advance(len)
    local at_continue, len = self:_at_name_cont()
    while at_continue do
        ret = ret .. self.buffer:advance(len)
        at_continue, len = self:_at_name_cont()
    end
    return ret
end

function Puller:_eat_qname()
    local first, err = self:_eat_name()
    if not first then
        return nil, err
    end
    local second
    if self.buffer:starts_with(':') then
        self:_advancebuffer(1) -- :
        second, err = self:_eat_name()
        if not second then
            return nil, err
        end
    end
    if self.buffer:starts_with(':') then
        return nil, string.format('Invalid name, only one prefix allowed @ %s', self.current_idx)
    end
    return first, second
end

function Puller:_at_name_start()
    if self.buffer:starts_with('[a-zA-Z:_]') then
        return true, 1
    end

    local ch, len = self.buffer:next_utf8_int()

    return ((ch >= 0x0000C0 and ch <= 0x0000D6)
        or (ch >= 0x0000D8 and ch <= 0x0000F6)
        or (ch >= 0x0000F8 and ch <= 0x0002FF)
        or (ch >= 0x000370 and ch <= 0x00037D)
        or (ch >= 0x00037F and ch <= 0x001FFF)
        or (ch >= 0x00200C and ch <= 0x00200D)
        or (ch >= 0x002070 and ch <= 0x00218F)
        or (ch >= 0x002C00 and ch <= 0x002FEF)
        or (ch >= 0x003001 and ch <= 0x00D7FF)
        or (ch >= 0x00F900 and ch <= 0x00FDCF)
        or (ch >= 0x00FDF0 and ch <= 0x00FFFD)
        or (ch >= 0x010000 and ch <= 0x0EFFFF)), len
end

function Puller:_at_name_cont()
    if self.buffer:starts_with('[a-zA-Z0-9_%-%.]') then
        return true, 1
    end
    local ch, len = self.buffer:next_utf8_int()
    if ch < 128 then
        return false
    end
    return (ch == 0x0000B7
        or (ch >= 0x0000C0 and ch <= 0x0000D6)
        or (ch >= 0x0000D8 and ch <= 0x0000F6)
        or (ch >= 0x0000F8 and ch <= 0x0002FF)
        or (ch >= 0x000300 and ch <= 0x00036F)
        or (ch >= 0x000370 and ch <= 0x00037D)
        or (ch >= 0x00037F and ch <= 0x001FFF)
        or (ch >= 0x00200C and ch <= 0x00200D)
        or (ch >= 0x00203F and ch <= 0x002040)
        or (ch >= 0x002070 and ch <= 0x00218F)
        or (ch >= 0x002C00 and ch <= 0x002FEF)
        or (ch >= 0x003001 and ch <= 0x00D7FF)
        or (ch >= 0x00F900 and ch <= 0x00FDCF)
        or (ch >= 0x00FDF0 and ch <= 0x00FFFD)
        or (ch >= 0x010000 and ch <= 0x0EFFFF)), len
end

function Puller.new(buffer, buffer_is_fragment)
    local st = state.declaration
    if buffer_is_fragment then
        st = state.elements
    end
    local ret = {
        ---@type string
        buffer = Buffer.new(buffer),
        depth = 0,
        state = st,
    }
    setmetatable(ret, Puller)
    return ret
end

function Puller:eat(s)
    return self.buffer:consume_str(s)
end

function Puller:_advancebuffer(ct)
    return self.buffer:advance(ct)
end

function Puller:_skip_whitespace()
    return self.buffer:skip_whitespace()
end

---Consume until the next `>`
---@return boolean
---@return string|nil
function Puller:_consume_decl()
    local _, err = self.buffer:consume_until('>')
    if err ~= nil then
        return false, err
    end
    self:_advancebuffer(1) -- >
    return true
end

function Puller:next()
    if self.buffer:at_end() then
        return event.Event.eof()
    end
    if self.state == state.declaration then
        self.state = state.after_declaration
        if self.buffer:starts_with('<%?xml') then
            return self:_parse_decl(self)
        else
            return self:next()
        end
    elseif self.state == state.after_declaration then
        if self.buffer:starts_with('<!DOCTYPE') then
            local tok, err = self:parse_doctype()
            if not tok then
                return tok, err
            end
            if tok.ty == event.event_type.doctype then
                self.state = state.after_doctype
            elseif tok.ty == event.event_type.doctype_start then
                self.state = state.doctype
            else
                return nil, 'Invalid doctype'
            end
            return tok, err
        elseif self.buffer:starts_with('<!--') then
            return self:parse_comment()
        elseif self.buffer:starts_with('<%?') then
            if self.buffer:starts_with('<?xml') then
                return nil, string.format('Invalid decl @ %s', self.current_idx)
            end
            return self:parse_pi()
        elseif self.buffer:at_space() then
            self.buffer:skip_whitespace()
            return self:next()
        else
            self.state = state.after_doctype
            return self:next()
        end
    elseif self.state == state.doctype then
        if self.buffer:starts_with('<!ENTITY') then
            return self:parse_entity_decl()
        elseif self.buffer:starts_with('<!--') then
            return self:parse_comment()
        elseif self.buffer:starts_with('<%?') then
            if self.buffer:starts_with('<%?xml') then
                return nil, string.format('Invalid doctype @ %s', self.current_idx)
            else
                self:parse_pi()
            end
        elseif self.buffer:starts_with(']') then
            self:_advancebuffer(1) -- ]
            self:_skip_whitespace()
            local current = self.buffer:current_char()
            if current == '>' then
                self.state = state.after_doctype
                self:_advancebuffer(1) -- >
                return event.Event.doctype_end()
            elseif current == nil then
                return nil, 'Unexpected EOF'
            else
                return nil, string.format('Invalid character in doctype expected > found %s', current)
            end
        elseif self.buffer:at_space() then
            self.buffer:skip_whitespace()
            return self:next()
        elseif self.buffer:starts_wth("<!ELEMENT") or self.buffer:starts_with("<!ATTLIST") or self.buffer:starts_with("<!NOTATION") then
            --TODO: these should be usable?
            local success, err = self:_consume_decl()
            if success then
                return self:next()
            else
                return nil, err
            end
        end
    elseif self.state == state.after_doctype then
        if self.buffer:starts_with('<!--') then
            return self:parse_comment()
        elseif self.buffer:starts_with('<!') then
            return nil, string.format('Unexpected token <! not followed by -- @ %s', self.current_idx)
        elseif self.buffer:starts_with('<') then
            self.state = state.attributes
            return self:parse_element_start()
        elseif self.buffer:at_space() then
            self.buffer:skip_whitespace()
            return self:next()
        else
            return nil, string.format('Invalid element, expected < found %s', self.buffer:current_char())
        end
    elseif self.state == state.elements then
        if self.buffer:starts_with('<!--') then
            return self:parse_comment()
        elseif self.buffer:at_cdata_start() then
            return self:parse_cdata()
        elseif self.buffer:starts_with('<%?xml') then
            return nil, 'Invalid declaration @' .. self.current_idx
        elseif self.buffer:starts_with('<%?') then
            return self:parse_pi()
        elseif self.buffer:starts_with('</') then
            if self.depth > 0 then
                self.depth = self.depth - 1
            end
            if self.depth == 0 and not self.fragment_parsing then
                self.state = state.after_elements
            else
                self.state = state.elements
            end
            return self:parse_close_element()
        elseif self.buffer:starts_with('<') then
            self.state = state.attributes
            return self:parse_element_start()
        else
            return self:parse_text()
        end
    elseif self.state == state.attributes then
        local ev, err = self:parse_attribute()
        if ev == nil then
            return nil, err
        end
        if ev.ty == event.event_type.tag_end then
            if not ev.is_empty then
                self.depth = self.depth + 1
                if self.depth == 0 and not self.fragment_parsing then
                    self.state = state.after_elements
                else
                    self.state = state.elements
                end
            end
        end
        return ev
    elseif self.state == state.after_elements then
        if self.buffer:starts_with('<!--') then
            return self:parse_comment()
        elseif self.buffer:starts_with('<%?xml') then
            return nil, 'Invalid declaration @ ' .. self.current_idx
        elseif self.buffer:starts_with('<?') then
            return self:parse_pi()
        elseif self.buffer:at_space() then
            self.buffer:skip_whitespace()
            return self:next()
        else
            return nil, string.format('Unknown token: %s', self.buffer:current_char())
        end
    else
        return nil, string.format('Invalid parser state `%s`', self.state)
    end
end



return Puller