local Field = require("dataclass.field")
local utils = require("dataclass.utils")

-- Test field initialization
local function test_initialization()
    local field = Field:new("name", "string", "John", {"John", "Jane"})
    assert(field ~= nil)

    local success, err = pcall(function()
        Field:new("age", "number", 30, {10, 20})
    end)
    assert(not success)
    assert(string.find(err, "default value is not among the choices"))

    local success, err = pcall(function()
        Field:new("age", "number", "30", nil)
    end)
    assert(not success)
    assert(string.find(err, "field 'age' must be a number"))

    local field = Field:new("gender", "string", nil, {"Male", "Female"})
    assert(field)
end

-- Test set_value method
local function test_set_value_method()
    local field = Field:new("age", "number", 30, {20, 30, 40})

    local value = field:set_value(40)
    assert(value == 40)

    local success, err = pcall(function()
        field:set_value("50")
    end)
    assert(not success)
    assert(string.find(err, "expected type: number"))

    local success, err = pcall(function()
        field:set_value(50)
    end)
    assert(not success)
    assert(string.find(err, "value is not among the choices"))
end

-- Run all tests
local function runtests()
    test_initialization()
    test_set_value_method()
    print("All tests passed successfully!")
end

runtests()
