local Dataclass = require("dataclass.dataclass")
local Field = require("dataclass.field")

-- Creating an immutable dataclass
local function test_create_immutable_dataclass()
    local fields = {
        Field:new("name", "string", "Unknown"),
        Field:new("age", "number", 0),
        Field:new("gender", "string", "Other", {"Male", "Female", "Other"})
    }

    local Person = Dataclass:new(fields, true)
    local person1 = Person({name = "Alice", age = 30, gender = "Female"})

    assert(person1.name == "Alice")
    assert(person1.age == 30)
    assert(person1.gender == "Female")
end

-- Immutability check
local function test_immutability()
    local fields = {
        Field:new("name", "string", "Unknown"),
        Field:new("age", "number", 0),
        Field:new("gender", "string", "Other", {"Male", "Female", "Other"})
    }

    local Person = Dataclass:new(fields, true)
    local person1 = Person({name = "Alice", age = 30, gender = "Female"})

    local success, err = pcall(function()
        person1.name = "Bob"
    end)

    assert(not success)
    assert(err:match("An immutable dataclass cannot be modified"))
end

-- Creating a mutable dataclass
local function test_create_mutable_dataclass()
    local fields = {
        Field:new("brand", "string", "Unknown"),
        Field:new("model", "string", "Unknown"),
        Field:new("year", "number", 2000)
    }

    local Car = Dataclass:new(fields, false)
    local car1 = Car({brand = "Toyota", model = "Corolla", year = 2021})
    car1.model = "Camry"

    assert(car1.model == "Camry")
end

-- Field validation and choices
local function test_field_validation_and_choices()
    local fields = {
        Field:new("name", "string", "Unknown Product"),
        Field:new("price", "number", 0.0),
        Field:new("category", "string", "Others", {"Electronics", "Furniture", "Clothing", "Others"})
    }

    local Product = Dataclass:new(fields)
    local product1 = Product({name = "Laptop", price = 1200.00, category = "Electronics"})

    local success, err = pcall(function()
        product1.category = "Food"
    end)

    assert(not success)
    assert(err:match("Error in Field:set_value: value is not among the choices"))
end

-- Initialization hooks
local function test_custom_initialization_hooks()
    local userFields = {
        Field:new("username", "string"),
        Field:new("email", "string"),
        Field:new("is_active", "boolean", false)
    }

    local User = Dataclass:new(userFields)

    function User:before_init(fields)
        self:add_field(Field:new("created_at", "string", os.date("%Y-%m-%d %H:%M:%S")))
        return fields
    end

    function User:after_init()
        self.values.initialized = true
    end

    local user1 = User({username = "john_doe", email = "john@example.com", is_active = true})

    assert(user1.username == "john_doe")
    assert(user1.email == "john@example.com")
    assert(user1.is_active)
    assert(user1.created_at)
    assert(user1.values.initialized)
end

-- Converting to table
local function test_to_table()
    local fields = {
        Field:new("name", "string", "Unknown"),
        Field:new("age", "number", 0),
        Field:new("gender", "string", "Other", {"Male", "Female", "Other"})
    }

    local Person = Dataclass:new(fields, true)
    local person1 = Person({name = "Alice", age = 30, gender = "Female"})
    local tbl = person1:to_table()

    assert(tbl.name == "Alice")
    assert(tbl.age == 30)
    assert(tbl.gender == "Female")
end

-- Run all tests
local function runtests()
    test_create_immutable_dataclass()
    test_immutability()
    test_create_mutable_dataclass()
    test_field_validation_and_choices()
    test_custom_initialization_hooks()
    test_to_table()
    print("All tests passed successfully!")
end

runtests()