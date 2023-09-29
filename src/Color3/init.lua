--// Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local primitiveLoaders = require(ReplicatedStorage.Packages.DataLoader.primitives)
local structLoader = require(ReplicatedStorage.Packages.DataLoader.struct)
local baseLoader = require(ReplicatedStorage.Packages.DataLoader.base)
type DataLoader<loaded, serialized> = baseLoader.DataLoader<loaded, serialized>

--// Module
return function(default: Color3?): DataLoader<Color3, { R: number, G: number, B: number }>
    
    local self = structLoader{
        R = primitiveLoaders.integer(0, 0, 255),
        G = primitiveLoaders.integer(0, 0, 255),
        B = primitiveLoaders.integer(0, 0, 255)
    }
    self.kind = "Color3"
    
    --// Override Methods
    local super = self.deserialize
    function self:deserialize(data)
        
        data = super(self, data)
        return Color3.fromRGB(data.R, data.G, data.B)
    end
    function self:serialize(color)
        
        return { R = color.R, G = color.G, B = color.B }
    end
    
    local super = self.wrapHandler
    function self:wrapHandler(container: Color3Value?)
        
        return super(self, container or Instance.new("Color3Value"))
    end
    
    --// End
    if default then self:setDefaultData{ R = math.floor(default.R*255), G = math.floor(default.G*255), B = math.floor(default.B*255) } end
    return self
end