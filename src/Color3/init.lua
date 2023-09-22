--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataLoader = require(ReplicatedStorage.Packages.DataLoader)
type DataLoader<loaded, serialized> = DataLoader.DataLoader<loaded, serialized>

local structLoader = require(ReplicatedStorage.Packages.DataLoader.struct)

--// Module
return function(default: Color3?): DataLoader<Color3, { R: number, G: number, B: number }>
    
    type data = { R: number, G: number, B: number }
    
    local self = structLoader{
        R = DataLoader.integer(0),
        G = DataLoader.integer(0),
        B = DataLoader.integer(0)
    }
    self.kind = "Color3"
    
    --// Override Methods
    local super = self.deserialize
    function self:deserialize(data: data): Color3
        
        data = super(self, data)
        return Color3.fromRGB(data.R, data.G, data.B)
    end
    function self:serialize(color: Color3): data
        
        return { R = color.R, G = color.G, B = color.B }
    end
    
    --// End
    if default then self:setDefaultData{ R = math.floor(default.R*255), G = math.floor(default.G*255), B = math.floor(default.B*255) } end
    return self
end