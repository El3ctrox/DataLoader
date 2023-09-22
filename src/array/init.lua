--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataLoader = require(ReplicatedStorage.Packages.DataLoader)
type DataLoader<loaded, serialized> = DataLoader.DataLoader<loaded, serialized>

local handler = require(script.handler)

--// Types
export type array<element> = { element }
export type serializedArray<element> = { element }

--// Module
return function<loadedElement, serializedElement>(
    elementLoader: DataLoader<loadedElement, serializedElement>?,
    minLength: number?, maxLength: number?
)
    elementLoader = elementLoader or DataLoader.new()
    
    local self = DataLoader.new({}) :: DataLoader<array<loadedElement>, serializedArray<serializedElement>>
    self.kind = "array"
    
    type sorter = (loadedElement, loadedElement) -> boolean
    self.sorter = nil :: sorter?
    
    self.element = elementLoader
    self.min = minLength
    self.max = maxLength
    
    --// Methods
    function self:sortBy(sorter: (loadedElement, loadedElement) -> boolean)
        
        self.sorter = sorter
        return self
    end
    
    --// Override Methods
    function self:getDefaultData()
        
        return table.clone(self.defaultData)
    end
    
    function self:check(data)
        
        assert(typeof(data) == "table", `array expected`)
        assert(not minLength or #data >= minLength, `a minimum of {minLength} elements expected`)
        assert(not maxLength or #data <= maxLength, `a maximum of {maxLength} elements expected`)
        
        for _,value in ipairs(data) do
            
            elementLoader:check(value)
        end
    end
    function self:correct(data)
        
        if typeof(data) ~= "table" then return end
        
        for index, value in ipairs(data) do
            
            if elementLoader:tryCheck(value) then return end
            
            local correction = elementLoader:correct(value)
            if correction then
                
                data[index] = correction
            else
                
                table.remove(data, index)
            end
        end
        
        return data
    end
    
    function self:deserialize(data)
        
        local array = {}
        
        for _,value in ipairs(data) do
            
            local loadedValue = elementLoader:deserialize(value)
            table.insert(array, loadedValue)
        end
        
        return array
    end
    function self:serialize(array)
        
        local data = {}
        
        for _,loadedValue in ipairs(array) do
            
            local value = elementLoader:serialize(loadedValue)
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