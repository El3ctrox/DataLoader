--// Types
export type DataHandler<loaded, serialized> = {
    load:   (DataHandler<loaded, serialized>, data: serialized) -> loaded,
    save:   (DataHandler<loaded, serialized>) -> serialized,
    
    set:    (DataHandler<loaded, serialized>, value: loaded) -> (),
    changed:(DataHandler<loaded, serialized>, value: loaded) -> (),
}

type ValueContainer<value> = ValueBase & { Value: value }

--// Module
return function<value>(loader, container: Instance|ValueContainer<value>?): DataHandler<value, value>
    
    local meta = { __metatable = "locked"}
    local self = setmetatable({ type = "attributeHandler", kind = loader.kind }, meta)
    local value: value
    
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