--// Packages
local baseLoader = require(script.Parent.base)
type baseLoader<type> = baseLoader.DataLoader<type, type>

--// Module
local primitives = {}

--// Functions
function primitives.any(default: any)
    
    return baseLoader(default) :: baseLoader<any>
end
function primitives.string(default: string?, minLength: number?, maxLength: number?)
    
    local self = baseLoader(default) :: baseLoader<string>
    self.kind = "string"
    
    self.min = minLength
    self.max = maxLength
    
    --// Override Methods
    function self:check(data)
        
        assert(typeof(data) == "string", `string expected`)
        assert(not minLength or #data >= minLength, `a minimum of {minLength} characters expected`)
        assert(not maxLength or #data <= maxLength, `a maximum of {maxLength} characters expected`)
    end
    function self:parse(data)
        
        if data == nil then return end
        return tostring(data)
    end
    
    local super = self.wrapHandler
    function self:wrapHandler(container)
        
        return super(self, container or Instance.new("StringValue"))
    end
    
    --// End
    return self
end
function primitives.integer(default: number?, min: number?, max: number?)
    
    local self = primitives.number(
        default and math.floor(default),
        min and math.floor(min),
        max and math.floor(max)
    ) :: baseLoader<number>
    self.kind = "integer"
    
    --// Override Methods
    local super = self.check
    function self:check(data)
        
        super(self, data)
        assert(data % 1 == 0, `integer cant have decimal cases`)
    end
    
    local super = self.correct
    function self:correct(data)
        
        data = super(self, data)
        if not data then return end
        
        return math.floor(data)
    end
    
    local super = self.wrapHandler
    function self:wrapHandler(container)
        
        return super(self, container or Instance.new("IntValue"))
    end
    
    --// End
    return self
end
function primitives.number(default: number?, min: number?, max: number?)
    
    local self = baseLoader(default) :: baseLoader<number>
    self.kind = "number"
    self.min = min
    self.max = max
    
    --// Override Methods
    function self:check(data)
        
        assert(typeof(data) == "number", `number expected`)
        assert(not min or data >= min, `a number >= {min} expected`)
        assert(not max or data <= max, `a number <= {max} expected`)
    end
    function self:correct(data)
        
        if typeof(data) == "string" then data = tonumber(data) end
        if typeof(data) ~= "number" then return end
        
        return math.clamp(data, min or -math.huge, max or math.huge)
    end
    
    local super = self.wrapHandler
    function self:wrapHandler(container)
        
        return super(self, container or Instance.new("NumberValue"))
    end
    
    --// End
    return self
end
function primitives.boolean(default: boolean?)
    
    local self = baseLoader(default) :: baseLoader<boolean>
    self.kind = "boolean"
    
    --// Methods
    function self:check(data)
        
        assert(typeof(data) == "boolean", `boolean expected`)
    end
    function self:correct(data)
        
        return if data then true else false
    end
    
    local super = self.wrapHandler
    function self:wrapHandler(container)
        
        return super(self, container or Instance.new("BoolValue"))
    end
    
    --// End
    return self
end

--// End
return primitives