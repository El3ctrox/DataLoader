--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

local handler = require(script.handler)

--// Types
export type array<element> = { element }
export type serializedArray<element> = { element }

--// Module
return function<loadedElement, serializedElement>(
    elementLoader: DataLoader<loadedElement, serializedElement>?,
    minLength: number?, maxLength: number?
)
    elementLoader = elementLoader or baseLoader.new()
    
    local self = baseLoader.new({}) :: DataLoader<array<loadedElement>, serializedArray<serializedElement>>
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
        if not elementLoader.canCorrect then return end
        
        local corrections = {}  -- logs corrections here instead apply changes without know if was possible correct all fields
        
        for index, value in ipairs(data) do
            
            corrections[index] = value
            if elementLoader:tryCheck(value) then continue end
            
            local correction = elementLoader:correct(value)
            corrections[index] = correction
        end
        
        for index in data do
            
            data[index] = corrections[index]
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
    
    function self:wrapHandler(container)
        
        return handler(self, container or Instance.new("Folder"))
    end
    
    --// End
    return self
end