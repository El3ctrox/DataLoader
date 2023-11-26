--// Packages
local structLoader = require(script.Parent.struct)
local arrayLoader = require(script.Parent.array)
local baseLoader = require(script.Parent.base)
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Types
export type map<key, value> = { [key]: value }

export type serializedPair<key, value> = { key: key, value: value }
export type serializedMap<key, value> = { serializedPair<key, value> }

--// Module
return function<loadedKey, loadedValue, serializedKey, serializedValue>(
    keyLoader: DataLoader<loadedKey, serializedKey>,
    valueLoader: DataLoader<loadedValue, serializedValue>
)
    keyLoader = keyLoader or baseLoader()
    valueLoader = valueLoader or baseLoader()
    
    local pair = structLoader{ key = keyLoader, value = valueLoader} :: DataLoader<{ key: loadedKey, value: loadedValue }, serializedPair<serializedKey, serializedValue>>
    local self = arrayLoader(pair) :: DataLoader<map<loadedKey, loadedValue>, serializedMap<serializedKey, serializedValue>>
    self.kind = "map"
    self.pair = pair
    
    --// Override Methods
    local super = self.serialize
    function self:serialize(map)
        
        local pairs = {}
        
        for key, value in map do
            
            table.insert(pairs, { key = key, value = value })
        end
        
        return super(self, pairs)
    end
    
    local super = self.deserialize
    function self:deserialize(data)
        
        local pairsData = super(self, data)
        local map = {}
        
        for _,pairData in pairsData do
            
            map[pairData.key] = pairData.value
        end
        
        return map
    end
    
    --// End
    return self
end