local utils = require("dataclass.utils")

local Field = {}
Field.__index = Field

function Field.__call(self, ...)
    return self:new(...)
end

function Field:new(name, field_type, default, choices)
    utils.assert_type(name, "string", "Error in Field:initialize: argument 'name' must be a string")
    utils.assert_type(field_type, "string", "Error in Field:initialize: argument 'field_type' must be a string")
    
    if default then
        assert(type(default) == field_type or field_type == "any", "Error in Field:initialize: field '" .. name .. "' must be a " .. field_type)
    end

    assert(choices == nil or type(choices) == "table", "Error in Field:initialize: argument 'choices' must be a table")

    if default and choices then
        utils.assert_choice(default, choices, "Error in Field:initialize: default value is not among the choices")
    end

    local instance = setmetatable({}, self)
    instance.name = name
    instance.field_type = field_type
    instance.value = default or nil
    instance.choices = choices or {}
    return instance
end

function Field:set_value(value)
    if value then
        if self.field_type ~= "any" and type(value) ~= self.field_type then
            error("Error in Field:set_value: expected type: " .. self.field_type .. ", got " .. type(value))
        end

        utils.assert_choice(value, self.choices, "Error in Field:set_value: value is not among the choices: " .. tostring(value))

        if self.validate then
            value = self:validate(value)
        end
    end

    return value or self.value
end

return Field