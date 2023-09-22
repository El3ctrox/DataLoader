--// Packages
local attributeHandler = require(script.attributeHandler)

--// Types
type dataHandler<loaded, serialized> = { load: (dataHandler<loaded, serialized>, data: serialized) -> loaded, save: (dataHandler<loaded, serialized>) -> serialized }
type table = { [any]: any }

--// Component
local DataLoader = {}
local dataLoaders = setmetatable({}, { __mode = "k" })

--// Constructor
function DataLoader.new<loaded, serialized>(defaultData: serialized?): DataLoader<loaded, serialized>
    
    local meta = { __metatable = "locked" }
    local self = setmetatable({ type = "DataLoader", kind = "abstract" }, meta)
    
    self.defaultData = defaultData
    self.isOptional = false -- unused here, only in builtin struct loader
    self.canCorrect = false
    self.canPanic = false
    
    --// Methods
    function self:setDefaultData(_defaultData: serialized | (DataLoader<loaded, serialized>) -> serialized): DataLoader<loaded, serialized>
        
        if typeof(_defaultData) == "function" then
            
            self.getDefaultData = _defaultData
            self.defaultData = nil
        else
            
            self.defaultData = _defaultData
        end
        
        return self
    end
    function self:getDefaultData(): serialized
        
        return self.defaultData
    end
    
    function self:shouldCorrect(): DataLoader<loaded, serialized>
        
        self.canCorrect = true
        return self
    end
    function self:shouldPanic(): DataLoader<loaded, serialized>
        
        self.canPanic = true
        return self
    end
    
    function self:shouldDiscart(): DataLoader<loaded, serialized>
        
        self.defaultData = nil
        return self
    end
    function self:optional(): DataLoader<loaded, serialized>
        
        self.isOptional = true
        return self
    end
    
    function self:correct(data: any): loaded?
        
        return data
    end
    function self:tryCheck(data: any): boolean
        
        return pcall(self.check, self, data)
    end
    function self:check(data: any)
    end
    
    function self:deserialize(data: serialized): loaded
        
        return data
    end
    function self:serialize(value: loaded): serialized
        
        return value
    end
    
    function self:load(data: serialized|any): loaded?
        
        if self.canCorrect and not self:tryCheck(data) then
            
            data = self:correct(data)
        end
        if self.defaultData ~= nil and not self:tryCheck(data) then
            
            data = self:getDefaultData()
        end
        if self.isOptional and data == nil then
            
            return
        end
        
        if self.canPanic then self:check(data)
            elseif not self:tryCheck(data) then return
        end
        
        return self:deserialize(data)
    end
    function self:save(data: loaded): serialized
        
        return self:serialize(data)
    end
    
    function self:handle(container: Instance?): dataHandler<loaded, serialized>
        
        local handler = self:_handle(container)
        if handler.roblox then dataLoaders[handler.roblox] = self end
        
        return handler
    end
    function self:_handle(container: Instance?): dataHandler<loaded, serialized>
        
        return attributeHandler(self)
    end
    
    --// Meta
    function meta:__tostring()
        
        return `DataLoader.{self.kind}(`
            .."should "..(if self.canCorrect then "correct" elseif self.isOptional then "give nil" else "give default")..", "
            .."should "..(if self.canPanic then "panic" else "be quiet")..", "
            .."default: "..(tostring(self:getDefaultData()))
            ..")"
    end
    
    --// End
    return self, meta
end

--// Functions
function DataLoader.any(default: any)
    
    return DataLoader.new(default) :: DataLoader<any, any>
end
function DataLoader.string(default: string?, minLength: number?, maxLength: number?)
    
    local self = DataLoader.new(default) :: DataLoader<string, string>
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
    
    --// End
    return self
end
function DataLoader.integer(default: number?, min: number?, max: number?)
    
    local self = DataLoader.number(
        default and math.floor(default),
        min and math.floor(min),
        max and math.floor(max)
    ) :: DataLoader<number, number>
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
    
    --// End
    return self
end
function DataLoader.number(default: number?, min: number?, max: number?)
    
    local self = DataLoader.new(default) :: DataLoader<number, number>
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
    
    --// End
    return self
end
function DataLoader.boolean(default: boolean?)
    
    local self = DataLoader.new(default) :: DataLoader<boolean, boolean>
    self.kind = "boolean"
    
    --// Methods
    function self:check(data)
        
        assert(typeof(data) == "boolean", `boolean expected`)
    end
    function self:correct(data)
        
        return if data then true else false
    end
    
    --// End
    return self
end

--// End
export type DataLoader<loaded, serialized> = {
    setDefaultData: (self: DataLoader<loaded, serialized>, defaultData: serialized | (DataLoader<loaded, serialized>) -> serialized) -> DataLoader<loaded, serialized>,
    getDefaultData: (self: DataLoader<loaded, serialized>) -> serialized,
    shouldCorrect:  (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    shouldPanic:    (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    shouldDiscart:  (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    optional:       (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    correct:        (self: DataLoader<loaded, serialized>, data: any) -> loaded?,
    tryCheck:       (self: DataLoader<loaded, serialized>, data: any) -> boolean,
    check:          (self: DataLoader<loaded, serialized>, data: any) -> (),
    deserialize:    (self: DataLoader<loaded, serialized>, data: serialized) -> loaded,
    serialize:      (self: DataLoader<loaded, serialized>, value: loaded) -> serialized,
    load:           (self: DataLoader<loaded, serialized>, data: serialized|any) -> loaded?,
    save:           (self: DataLoader<loaded, serialized>, data: loaded) -> serialized,
    handle:         (self: DataLoader<loaded, serialized>, container: Instance?) -> dataHandler<loaded, serialized>,
}
return DataLoader