--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wrapper = require(ReplicatedStorage.Packages.Wrapper)

local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataHandler<loaded, serialized> = baseLoader.DataHandler<loaded, serialized>
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function<element, serializedArray>(container: Instance, loader: DataLoader<{element}, serializedArray>): DataHandler<{element}, serializedArray>
    
    local elementLoader = loader.element :: DataLoader<element, any>
    local sorter = loader.sorter
    local values = {}
    
    local self = wrapper(container)
    
    --// Base Methods
    function self:load(serialized)
        
        self:set(loader:load(serialized))
        return values
    end
    function self:set(newValues: {element}, parent: Instance?, name: string?)
        
        if parent then container.Parent = parent end
        if name then container.Name = name end
        
        self:clear()
        self:add(unpack(newValues))
        self:changed(newValues)
    end
    
    --// Methods
    function self:get(...: number): ...element
        
        local values = {}
        
        for index, iIndex in {...} do
            
            values[index] = if iIndex > 0 then values[iIndex]
                else values[#values + iIndex + 1]
        end
        
        return unpack(values)
    end
    function self:unpack(): ...element
        
        return unpack(values)
    end
    function self:length(): number
        
        return #values
    end
    
    function self:insert<value>(index: number, value: value & element): value
        
        table.insert(values, if index > 0 then index else #values - index + 1, value)
        return value
    end
    function self:sortedAdd<value>(...: value & element): ...value
        
        if not sorter then
            
            warn(`implicity :add detected (because its a sorted array)`)
            return self:add(...)
        end
        
        --[[ SLOWER VERSION
        for _,value in {...} do
            
            for index, iValue in data do
                
                if sorter(value, iValue) then table.insert(data, index, value) end
            end
        end
        --]]
        local insertingValues = table.sort({...}, sorter)
        local insertingValue = insertingValues[1]
        local insertingIndex = 1
        
        for index, value in values do
            
            if sorter(insertingValue, value) then
                
                table.insert(values, index, value)
                
                insertingIndex += 1
                insertingValue = insertingValues[insertingIndex]
                if not insertingValue then break end
            end
        end
        
        return unpack(insertingValues)
    end
    function self:add<value>(...: value & element): ...value
        
        if sorter then
            
            warn(`implicity :sortedAdd detected (because its a sorted array)`)
            return self:sortedAdd(...)
        end
        
        for _,value in {...} do
            
            table.insert(values, value)
        end
        
        return ...
    end
    
    function self:remove(...: number): ...element
        
        local values = {}
        
        for index, removingIndex in {...} do
            
            values[index] = table.remove(values, removingIndex)
        end
        
        return unpack(values)
    end
    function self:removeRange(from: number, to: number?): ...element
        
        if not to then return table.remove(values, if from > 0 then from else #values - from + 1) end
        
        if from > 0 then assert(from < to, `from < to expected`)
                    else assert(from > to, `from > to expected`)
        end
        
        local removedValues = {}
        table.move(values, from, to, 1, removedValues)
        table.move(values, to+1, -1, from, values)
        
        return unpack(removedValues)
    end
    function self:removeValue(value: element, max: number?): number
        
        local occurences = 0
        
        for index, iValue in values do
            
            if value == iValue then
                
                occurences += 1
                table.remove(values, index)
            end
            
            if max and occurences >= max then break end
        end
        
        return occurences
    end
    function self:removeValues(...: element): ...number
        
        local indexes = {}
        
        for _,value in {...} do
            
            local index = table.find(values, value)
            if not index then break end
            
            table.insert(values, table.remove(values, index))
        end
        
        return unpack(indexes)
    end
    
    function self:findSome(max: number,...: element): ...number?
        
        local indexes = {}
        local count = 0
        
        for _,value in {...} do
            
            local index = table.find(values, value)
            if not index then continue end
            
            count += 1
            indexes[count] = index
            
            if count == max then break end
        end
        
        return unpack(indexes)
    end
    function self:findAll(...: element): ...number?
        
        local indexes = {}
        
        for index, value in {...} do
            
            local valueIndex = table.find(values, value)
            if not valueIndex then return end
            
            indexes[index] = valueIndex
        end
        
        return unpack(indexes)
    end
    
    function self:map<value, params...>(mapper: (value: value & element, params...) -> value?, ...: params...)
        
        local output = {}
        
        for _,value in values do
            
            table.insert(output, mapper(value,...))
        end
        
        return output
    end
    function self:mapPair<value, params...>(mapper: (index: number, value: value & element, params...) -> value?, ...: params...)
        
        local output = {}
        
        for index, value in values do
            
            table.insert(output, mapper(index, value,...))
        end
        
        return output
    end
    
    function self:foreach<params...>(iterator: (value: element, params...) -> (),...: params...)
        
        for _,value in values do iterator(value,...) end
    end
    function self:foreachPair<params...>(iterator: (index: number, value: element, params...) -> (),...: params...)
        
        for index, value in values do iterator(index, value,...) end
    end
    
    --// End
    return self
end