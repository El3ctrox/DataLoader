return function()
    
    local match = require(script.Parent.Parent.utils).match
    local arrayLoader = require(script.Parent.Parent.array)
    local DataLoader = require(script.Parent.Parent)
    local structLoader = require(script.Parent)
    
    local itemLoader = structLoader{
        name = DataLoader.string("unknown"),
        level = DataLoader.integer(1),
        color = DataLoader.string("white")
    }
    
    it("should load all fields", function()
        
        local data = { name = "sword", level = 2, color = "green" }
        local item = itemLoader:load(data)
        
        expect(match(item, { name = "sword", level = 2, color = "green" }))
    end)
    
    describe("loading default data (automatic infered/:setDefaultData)", function()
        
        it("should load default data when miss field", function()
            
            local data = { name = nil, level = 3, color = "green" }
            local item = itemLoader:load(data)
            
            expect(match(item, { level = 1, color = "white" })).to.be.ok()
        end)
        it("should load default data when miss data", function()
            
            local item = itemLoader:load("not a table")
            expect(match(item, { name = "unknown", level = 1, color = "white" })).to.be.ok()
        end)
        it("shouldnt give same default data address", function()
            
            local defaultItem1 = itemLoader:load(nil)
            local defaultItem2 = itemLoader:load(nil)
            
            expect(defaultItem1).to.be.ok()
            expect(defaultItem2).to.be.ok()
            expect(defaultItem1).never.to.be.equal(defaultItem2)
        end)
    end)
    describe("discartions (:shouldDiscart)", function()
        
        it("should discart when miss field", function()
            
            itemLoader:shouldDiscart()
            
            local data = { name = nil, level = 3, color = "red" }
            local item = itemLoader:load(data)
            
            expect(item).to.be.equal(nil)
        end)
        it("shouldnt discart when miss optional field", function()
            
            itemLoader:shouldDiscart()
            itemLoader.name:optional()
            
            local data = { name = nil, level = 3, color = "red" }
            local item = itemLoader:load(data)
            
            expect(match(item, { level = 3, color = "red" })).to.be.ok()
        end)
        it("should discart when miss data", function()
            
            itemLoader:shouldDiscart()
            
            local item = itemLoader:load("not a table")
            expect(item).to.be.equal(nil)
        end)
    end)
    describe("corrections (:shouldCorrect)", function()
        
        it("should correct filling missing fields", function()
            
            itemLoader:shouldCorrect()
            
            local data = { name = "sword", level = 1 }
            local item = itemLoader:load(data)
            
            expect(match(item, {
                name = "sword",
                level = 1,
                color = "white"
            })).to.be.ok()
            expect(match(data, {
                name = "sword",
                level = 1,
                color = "white"
            })).to.be.ok()
        end)
        it("should correct converting missing fields", function()
            
            itemLoader:shouldCorrect()
            
            local data = { name = "potion", level = "3", color = "red" }
            local item = itemLoader:load(data)
            
            expect(match(item, { name = "potion", level = 3, color = "red" })).to.be.ok()
        end)
    end)
    describe("adding fields (:insert or __newindex)", function()
        
        it("should add a field", function()
            
            itemLoader.damage = 0
            
            local item = itemLoader:load{ damage = nil, name = "sword" }
            
            expect(match(item, { damage = 0, name = "sword", level = 1, color = "white" })).to.be.ok()
        end)
        it("should add a loader", function()
            
            itemLoader.owners = arrayLoader(
                DataLoader.integer()
            )
            
            local item = itemLoader:load{ owners = nil, name = "sword" }
            
            expect(match(item, { owners = {}, damage = 0, name = "sword", level = 1, color = "white" })).to.be.ok()
        end)
    end)
end