local Field = require("dataclass.field")
local utils = require("dataclass.utils")

local Dataclass = {}
Dataclass.__index = Dataclass

function Dataclass.__index(self, key)
    local values = rawget(self, "values")
    if values and values[key] ~= nil then
        return values[key]
    end

    local instance_value = rawget(self, key)
    if instance_value then
        return instance_value
    end
    
    local class_value = rawget(Dataclass, key)
    if class_value then
        return class_value
    end
end

function Dataclass.__newindex(self, key, value)
    if self.attributes and self.attributes[key] then
        if not self.immutable then
            local field = self.attributes[key]
            assert(field ~= nil, "Error in Dataclass:__newindex: unsupported attribute: " .. key)
            self.values[key] = field:set_value(value)
        else
            error("An immutable dataclass cannot be modified")
        end
    else
        rawset(self, key, value)
    end
end

function Dataclass.__call(self, ...)
    if self.is_instance then
        local values = select(1, ...)
        utils.assert_type(values, "table", "Dataclass:__call: argument 'values' must be a table")

        if self.before_init then
            values = self:before_init(values) or values
        end

        for key, value in pairs(values) do
            self.values[key] = value
        end

        if self.after_init then
            self:after_init()
        end

        return self
    end

    return self:new(...)
end

function Dataclass.__eq(self, other)
    if type(other) ~= "table" or getmetatable(other) ~= getmetatable(self) then
        return false
    end

    if self.classname ~= other.classname then
        return false
    end

    for k, v in pairs(self.values) do
        if other.values[k] ~= v then
            return false
        end
    end

    for k, v in pairs(other.values) do
        if self.values[k] ~= v then
            return false
        end
    end

    return true
end

function Dataclass:new(fields, immutable)
    utils.assert_type(fields, "table", "Error in Dataclass:new: argument 'fields' must be a table")
    if immutable ~= nil then
        utils.assert_type(immutable, "boolean", "Error in Dataclass:new: argument 'immutable' must be a boolean")
    end

    local instance = setmetatable({}, self)
    instance.values = {}
    instance.attributes = {}
    instance.immutable = immutable or false
    instance.is_instance = true

    for _, field in ipairs(fields) do
        utils.assert_type(field, "table", "Error in Dataclass:new: fields must be a table or Field instance")
        instance:add_field(field)
    end

    return instance
end

function Dataclass:add_field(field)
    if not field.new then
        field = Field:new(field.name, field.type, field.value)
    end
        
    self.attributes[field.name] = field
    self.values[field.name] = field:set_value()
end

function Dataclass:to_table()
    local tbl = {}
    for key, value in pairs(self.values) do
        tbl[key] = value
    end
    return tbl
end

return Dataclass