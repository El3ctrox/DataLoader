local function match(data, pattern: { [any]: any })
    
    if typeof(pattern) == "table" then
        
        if typeof(data) ~= "table" then return false end
        
        for index, patternValue in pattern do
            
            if not match(data[index], patternValue) then return false end
        end
        
        for index in data do
            
            if pattern[index] == nil then return false end
        end
        
        return true
        
    elseif typeof(pattern) == "string" then
        
        return typeof(data) == "string" and pattern:match(data)
    else
        
        return data == pattern
    end
end
local function xtypeof(value: any): string
    
    return if typeof(value) == "table" then rawget(value, "type") or "table" else typeof(value)
end

--// Export
return {
    xtypeof = xtypeof,
    match = match,
}