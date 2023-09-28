--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local arrayLoader = require(ReplicatedStorage.Packages.DataLoader.array)
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
    
    local self = arrayLoader()
    self.kind = "set"
    
    self.value = valueLoader
    self.min = minLength
    self.max = maxLength
    
    --// Override Methods
    local super = self.deserialize
    function self:deserialize(data: serializedSet<serializedValue>): loadedSet<loadedValue>
        
        data = super(self, data)
        local set = {}
        
        for value in data do
            
            local loadedValue = valueLoader:deserialize(value)
            if not loadedValue then return end
            
            set[loadedValue] = true
        end
        
        return set
    end
    
    local super = self.serialize
    function self:serialize(set: loadedSet<loadedValue>): serializedSet<serializedValue>
        
        local data = {}
        
        for value in set do
            
            table.insert(data, value)
        end
        
        return super(self, data)
    end
    
    function self:wrapHandler(container)
        
        if container then container.Parent = self.rootContainer end
        return handler(self, container or Instance.new("Folder", self.rootContainer))
    end
    
    --// End
    return self
end