--// Module
return function(loader)
    
    local meta = { __metatable = "locked"}
    local self = setmetatable({ type = "attributeHandler", kind = loader.kind }, meta)
    local value: any
    
    --// Methods
    function self:load(data)
        
        value = loader:load(data)
        self:set(value)
        
        return value
    end
    function self:save()
        
        return loader:serialize(value)
    end
    
    function self:set(newValue, parent, name)
        
        if parent and name then
            
            parent:SetAttribute(name, newValue)
        end
        
        value = newValue
    end
    
    --// End
    return self
end