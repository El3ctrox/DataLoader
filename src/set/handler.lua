--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wrapper = require(ReplicatedStorage.Packages.Wrapper)

local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataHandler<loaded, serialized> = baseLoader.DataHandler<loaded, serialized>
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function<element, serializedArray>(loader: DataLoader<{element}, serializedArray>, container: Instance): DataHandler<{element}, serializedArray>
    
    local elementLoader = loader.element
    local handlers = {}
    local values = {}
    
    local self = wrapper(container)
    
    --// Base Methods
    function self:load(serialized)
        
        local newValues = loader:load(serialized)
        self:set(newValues)
        
        return newValues
    end
    function self:save()
        
        return loader:serialize(values)
    end
    
    function self:set(newSet: { [element]: true }, parent: Instance?, name: string?)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        local newValues = {}
        for value in newSet do table.insert(newValues, value) end
        
        self:clear()
        self:add(unpack(newValues))
    end
    
    --// Methods
    local function insert(value: element)
        
        if values[value] then return end
        
        local handler = elementLoader:handle()
        self:_host(handler)
        
        values[value] = true
        handler:set(value, container)
        
        return value
    end
    local function remove(value: element)
        
        if not values[value] then return end
        
        local handler = handlers[value]
        if not handler then return end
        
        values[value] = nil
        handler:Destroy()
        
        return value
    end
    
    function self:length(): number
        
        return #values
    end
    
    function self:add<value>(...: value & element): ...value
        
        local insertedValues = {}
        
        for _,value in {...} do
            
            table.insert(insertedValues, insert(value))
        end
        
        return unpack(insertedValues)
    end
    function self:remove(...: element): ...boolean
        
        local removedValues = {}
        
        for _,value in {...} do
            
            table.insert(removedValues, remove(value))
        end
        
        return unpack(removedValues)
    end
    
    function self:findSome(max: number,...: element): ...boolean?
        
        local foundElements = {}
        local count = 0
        
        for _,value in {...} do
            
            if not values[value] then continue end
            
            count += 1
            foundElements[count] = value
            
            if count == max then break end
        end
        
        return unpack(foundElements)
    end
    function self:findAll(...: element): boolean
        
        local foundElements = {}
        
        for index, value in {...} do
            
            foundElements[index] = values[value] ~= nil
        end
        
        return unpack(foundElements)
    end
    
    function self:map<value, params...>(mapper: (value: value & element, params...) -> value?, ...: params...)
        
        local output = {}
        
        for value in values do
            
            table.insert(output, mapper(value,...))
        end
        
        return output
    end
    function self:foreach<params...>(iterator: (value: element, params...) -> (),...: params...)
        
        for value in values do iterator(value,...) end
    end
    
    --// End
    return self
end