--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

local handler = require(script.handler)

--// Module
export type loadedSet<value> = { [value]: true }
export type serializedSet<value> = { value }

return function<loadedValue, serializedValue>(
    valueLoader: DataLoader<loadedValue, serializedValue>?,
    minLength: number?, maxLength: number?
): DataLoader<loadedSet<loadedValue>, serializedSet<serializedValue>>
    
    local self = baseLoader({})
    self.kind = "set"
    
    self.value = valueLoader
    self.min = minLength
    self.max = maxLength
    
    --// Override Methods
    function self:getDefaultData()
        
        return table.clone(self.defaultData)
    end
    
    function self:deserialize(data: serializedSet<serializedValue>): loadedSet<loadedValue>
        
        local set = {}
        
        for value in data do
            
            local loadedValue = valueLoader:deserialize(value)
            if not loadedValue then return end
            
            set[loadedValue] = true
        end
        
        return set
    end
    function self:serialize(set: loadedSet<loadedValue>): serializedSet<serializedValue>
        
        local data = {}
        
        for value in set do
            
            table.insert(data, value)
        end
        
        return data
    end
    
    function self:_handle(container)
        
        return handler(self, container or Instance.new("Folder"))
    end
    
    --// End
    return self
end