--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wrapper = require(ReplicatedStorage.Packages.Wrapper)
local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataHandler<loaded, serialized> = baseLoader.DataHandler<loaded, serialized>
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function<loaded, serialized>(loader: DataLoader<loaded, serialized>, container: Instance): DataHandler<loaded, serialized>
    
    local self = wrapper(container)
    local loaders = loader.loaders
    
    local values = {}
    local handlers = {} do
        
        for index, subLoader in loaders do
            
            handlers[index] = subLoader:wrapHandler()
        end
    end
    
    self.changed = self:_signal("changed")
    
    --// Methods
    function self:load(serialized)
        
        self:set(loader:load(serialized))
        return values
    end
    function self:save()
        
        return loader:serialize(values)
    end
    
    function self:handleLoader(index: string, subLoader: DataLoader<any, any>, handlerContainer: Instance?)
        
        local handler = subLoader:wrapHandler(handlerContainer)
        handlers[index] = handler
        
        loader:insert(index, subLoader)
        return handler
    end
    function self:getHandlers(): { [string]: DataHandler<any, any>}
        
        return handlers
    end
    
    function self:set(newValues: loaded, parent: Instance?, name: string?)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        for index, subLoader in loaders do
            
            local subHandler = handlers[index] or self:handleLoader(index, subLoader)
            local value = newValues[index]
            
            subHandler:set(value, container, index)
        end
        
        values = newValues
        self.changed:_emit(newValues)
    end
    function self:get(): loaded
        
        return values
    end
    
    --// End
    return self
end