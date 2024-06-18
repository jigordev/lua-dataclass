# Lua Dataclass Library

A simple yet powerful dataclass implementation for Lua, inspired by Python's dataclasses. This library allows you to define data structures with minimal boilerplate, supports immutability, type validation, default values, and more.

## Installation

Include the `dataclass` module in your project.

## Usage

### Creating a Dataclass

To create a dataclass, you need to define the fields and instantiate a `Dataclass`.

```lua
local dataclass = require("dataclass")

local fields = {
    {name = "name", type = "string", value = "Unknown"},
    {name = "age", type = "number", value = 0},
    dataclass.Field:new("gender", "string", "Other", {"Male", "Female", "Other"}) -- With Field class
}

local Person = Dataclass:new(fields)

local person1 = Person({name = "Alice", age = 30, gender = "Female"})

print(person1.name) -- Alice
print(person1.age) -- 30
print(person1.gender) -- Female
```

### Immutability

By default, dataclasses are mutable. This means you can change its attributes after instantiation.

```lua
local success, err = pcall(function()
    person1.name = "Bob"
end)

print(success) -- true
```

If you want a immutable dataclass, set the second parameter to `true`.

```lua
local Car = Dataclass:new({
    Field("brand", "string", "Unknown"),
    Field("model", "string", "Unknown"),
    Field("year", "number", 2000)
}, true)

local car1 = Car({brand = "Toyota", model = "Corolla", year = 2021})

local success, err = pcall(function()
    car1.model = "Camry"
end)

print(success) -- false
print(err) -- An immutable dataclass cannot be modified
```

### Field Validation and Choices

You can define fields with specific types and a set of valid choices.

```lua
local Product = Dataclass:new({
    Field:new("name", "string", "Unknown Product"),
    Field:new("price", "number", 0.0),
    Field:new("category", "string", "Others", {"Electronics", "Furniture", "Clothing", "Others"})
})

local product1 = Product({name = "Laptop", price = 1200.00, category = "Electronics"})

local success, err = pcall(function()
    product1.category = "Food"
end)

print(success) -- false
print(err)     -- Error in Field:set_value: value is not among the choices: Food
```

### Custom Initialization Hooks

You can define custom `before_init` and `after_init` methods in your dataclass.

```lua
local userFields = {
    Field:new("username", "string"),
    Field:new("email", "string"),
    Field:new("is_active", "boolean", false)
}

local User = Dataclass:new(userFields)

function User:before_init(values)
    self:add_field(Field:new("created_at", "string"))
    values["created_at"] = os.date("%Y-%m-%d %H:%M:%S")
    return values
end

function User:after_init()
    print("User " .. self.values.username .. " created at " .. self.values.created_at)
end

local user1 = User({username = "john_doe", email = "john@example.com", is_active = true})

print(user1.username) -- john_doe
print(user1.email) -- john@example.com
print(user1.is_active) -- true
print(user1.created_at) -- (current date and time)
```

### Converting to a Table

You can easily convert a dataclass instance to a table.

```lua
local tbl = user1:to_table()
for k, v in pairs(tbl) do
    print(k, v)
end
```

## API Reference

### Dataclass(fields, immutable)

- `fields`: A table containing `Field` instances.
- `immutable`: A boolean indicating if the dataclass should be immutable. Defaults to `false`.

### Field(name, field_type, default, choices)

- `name`: The name of the field.
- `field_type`: The type of the field (e.g., "string", "number", "boolean", or "any").
- `default`: The default value for the field.
- `choices`: An optional table of valid choices for the field.

### Methods

- `Dataclass:add_field()`: Add new field by table or field instance.
- `Dataclass:to_table()`: Converts the dataclass instance to a table.
- `Dataclass:__call(values)`: Sets values for the dataclass instance.
- `Dataclass:__eq(other)`: Checks if two dataclass instances are equal.

## Contributing

Feel free to open issues or submit pull requests for improvements and bug fixes.

## License

This project is licensed under the MIT License.