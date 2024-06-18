local utils = {}

function utils.contains(list, value)
    for _, v in ipairs(list) do
        if value == v then
            return true
        end
    end
    return false
end

function utils.assert_type(var, expected_type, msg)
    assert(type(var) == expected_type, msg)
end

function utils.assert_choice(value, choices, msg)
    if choices and next(choices) ~= nil then
        assert(utils.contains(choices, value), msg)
    end
end

return utils