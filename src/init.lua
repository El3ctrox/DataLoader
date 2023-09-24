--// Packages
local primitives = require(script.primitives)
local base = require(script.base)

--// Index
export type DataHandler<loaded, serialized> = base.DataHandler<loaded, serialized>
export type DataLoader<loaded, serialized> = base.DataLoader<loaded, serialized>

return {
    array = require(script.array),
    Color3 = require(script.Color3),
    map = require(script.map),
    set = require(script.set),
    struct = require(script.struct),
    
    any = base,
    string = primitives.string,
    number = primitives.number,
    integer = primitives.integer,
    boolean = primitives.boolean,
}