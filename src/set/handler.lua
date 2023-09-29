--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wrapper = require(ReplicatedStorage.Packages.Wrapper)

local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataHandler<loaded, serialized> = baseLoader.DataHandler<loaded, serialized>
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function<element, serializedArray>(loader: DataLoader<{element}, serializedArray>, container: Instance): DataHandler<{element}, serializedArray>
    
    local self = wrapper(container)
    local elementLoader = loader.element
    local handlers = {}
    local values = {}
    
    --// Base Methods
    function self:load(serialized)
        
        self:set(loader:load(serialized))
        return values
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
        self:changed(newSet)
    end
    function self:changed(newSet: { [element]: true })
    end
    
    --// Methods
    local function insert(value: element)
        
        if values[value] then return end
        
        local handler = elementLoader:wrapHandler()
        self:_host(handler)
        
        values[value] = true
        handler:set(value, container)
        
        return value
    end
    local function remove(value: element)
        
        if not values[value] then return end
        
        local handler = handlers[value]
        if not handler then return end
        
        handler.Parent = nil
        values[value] = nil
        
        return value
    end
    
    function self:length(): number
        
        local total = 0
        for _ in values do total += 1 end
        
        return total
    end
    function self:clear(): number
        
        local total = 0
        
        for value, handler in handlers do
            
            handler.Parent = nil
            values[value] = nil
            
            total += 1
        end
        
        return total
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