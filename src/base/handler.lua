--// Packages
local wrapper = require(script.Parent.Parent.Parent.Wrapper)
local Signal = require(script.Parent.Parent.Parent.Signal)
type Signal<T...> = Signal.Signal<T...>

--// Types
export type DataHandler<loaded, serialized> = {
    load:   (DataHandler<loaded, serialized>, data: serialized) -> loaded,
    save:   (DataHandler<loaded, serialized>) -> serialized,
    
    set:    (DataHandler<loaded, serialized>, value: loaded, parent: Instance?, name: string?) -> (),
    get:    (DataHandler<loaded, serialized>) -> loaded,
    
    changed: Signal<loaded, loaded>
}

type ValueContainer<value> = ValueBase & { Value: value }

--// Module
return function<value>(loader, container: Instance|ValueContainer<value>): DataHandler<value, value>
    
    local self = wrapper(container)
    local value: value
    
    self.changed = self:_signal("changed")
    
    --// Methods
    function self:load(data)
        
        self:set(loader:load(data))
        return value
    end
    function self:save()
        
        return loader:serialize(value)
    end
    
    function self:set(newValue, parent, name)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        if parent and name then
            
            parent:SetAttribute(name, newValue)
            parent:GetAttributeChangedSignal(name):Connect(function()
                
                value = parent:GetAttribute(name)
                self.changed:_emit(value)
            end)
            
            container.Parent = nil
        end
        
        value = newValue
        self.changed:_emit(newValue)
    end
    function self:get(): value
        
        return value
    end
    
    --// Listeners
    if container and container:IsA("ValueBase") then
        
        container:GetPropertyChangedSignal("Value"):Connect(function()
            
            value = container.Value
            self.changed:_emit(value)
        end)
        
        value = container.Value
    end
    
    --// End
    return self
end