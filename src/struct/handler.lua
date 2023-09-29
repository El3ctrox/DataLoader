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
    
    --// Methods
    function self:load(serialized)
        
        self:set(loader:load(serialized))
        return values
    end
    function self:save()
        
        return loader:serialize(values)
    end
    
    function self:set(newValues: loaded, parent: Instance?, name: string?)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        for index, subLoader in loaders do
            
            local subHandler = subLoader:wrapHandler()
            local value = newValues[index]
            
            subHandler:set(value, container, index)
        end
        
        values = newValues
        self:changed(newValues)
    end
    function self:changed(newValues: loaded)
    end
    
    --// End
    return self
end