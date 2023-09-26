--// Packages
local wrapHandler = require(script.handler)

--// Types
type table = { [any]: any }

export type DataHandler<loaded, serialized> = {
    set:    (DataHandler<loaded, serialized>, value: loaded) -> (),
    load:   (DataHandler<loaded, serialized>, data: serialized) -> loaded,
    save:   (DataHandler<loaded, serialized>) -> serialized,
}
export type DataLoader<loaded, serialized> = {
    setDefaultData: (self: DataLoader<loaded, serialized>, defaultData: serialized | (DataLoader<loaded, serialized>) -> serialized) -> DataLoader<loaded, serialized>,
    getDefaultData: (self: DataLoader<loaded, serialized>) -> serialized,
    shouldCorrect:  (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    shouldDiscart:  (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    shouldPanic:    (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    optional:       (self: DataLoader<loaded, serialized>) -> DataLoader<loaded, serialized>,
    correct:        (self: DataLoader<loaded, serialized>, data: any) -> loaded?,
    tryCheck:       (self: DataLoader<loaded, serialized>, data: any) -> boolean,
    check:          (self: DataLoader<loaded, serialized>, data: any) -> (),
    deserialize:    (self: DataLoader<loaded, serialized>, data: serialized) -> loaded,
    serialize:      (self: DataLoader<loaded, serialized>, value: loaded) -> serialized,
    load:           (self: DataLoader<loaded, serialized>, data: serialized|any) -> loaded?,
    save:           (self: DataLoader<loaded, serialized>, data: loaded) -> serialized,
    wrapHandler:    (self: DataLoader<loaded, serialized>, container: Instance?) -> DataHandler<loaded, serialized>,
}

return function<loaded, serialized>(defaultData: serialized?): DataLoader<loaded, serialized>
    
    local meta = { __metatable = "locked" }
    local self = setmetatable({ type = "DataLoader", kind = "abstract" }, meta)
    
    self.defaultData = defaultData
    self.rootContainer = nil :: Instance?
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
    function self:shouldDiscart(): DataLoader<loaded, serialized>
        
        self.defaultData = nil
        return self
    end
    function self:shouldPanic(): DataLoader<loaded, serialized>
        
        self.canPanic = true
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
    
    function self:wrapHandler(container: Instance?): DataHandler<loaded, serialized>
        
        if container then container.Parent = self.rootContainer end
        return wrapHandler(self, container)
    end
    function self:setRootContainer(rootContainer: Instance)
        
        self.rootContainer = rootContainer
        return self
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