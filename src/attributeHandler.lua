--// Module
return function(loader)
    
    local meta = { __metatable = "locked"}
    local self = setmetatable({ type = "attributeHandler", kind = loader.kind }, meta)
    local value: any
    local data: any
    
    --// Methods
    function self:load(_data)
        
        data = _data
        loader:load(data)
        
        self:apply(value)
        return self
    end
    function self:set(newValue, parent, name)
        
        if parent and name then
            
            parent:SetAttribute(name, newValue)
        end
        
        value = newValue
        return self
    end
    
    --// End
    return self
end