return function()
    
    local match = require(script.Parent.Parent.utils).match
    local DataLoader = require(script.Parent.Parent)
    local arrayLoader = require(script.Parent)
    
    local itemsLoader = arrayLoader(DataLoader.string("unknown"))
    
    it("should load all elements", function()
        
        local data = { "sword", "apple" }
        local items = itemsLoader:load(data)
        
        expect(match(items, { "sword", "apple" })).to.be.ok()
    end)
    
    describe("loading default data (:setDefaultData)", function()
        
        it("should load default data when miss element", function()
            
            local data = { "string", 10, "cavalo" }
            local items = itemsLoader:load(data)
            
            expect(match(items, {})).to.be.ok()
        end)
        it("should load default data when miss data", function()
            
            local items = itemsLoader:load("not a array")
            expect(match(items, {})).to.be.ok()
        end)
        it("shouldnt give same default data address", function()
            
            local defaultItems1 = itemsLoader:load()
            local defaultItems2 = itemsLoader:load()
            
            expect(defaultItems1).to.be.ok()
            expect(defaultItems2).to.be.ok()
            expect(defaultItems1).never.to.be.equal(defaultItems2)
        end)
    end)
    describe("discartions (:shouldDiscart)", function()
        
        it("should discart all if some miss element", function()
            
            itemsLoader:shouldDiscart()
            
            local data = { "armor", 5, "cavalo" }
            local items = itemsLoader:load(data)
            
            expect(match(items, {})).to.be.ok()
        end)
        it("should discart when miss data", function()
            
            itemsLoader:shouldDiscart()
            
            local color = itemsLoader:load("not a array")
            expect(color).to.be.equal(nil)
        end)
    end)
    describe("corrections (:shouldCorrect)", function()
        
        it("should correct discarting miss elements", function()
            
            itemsLoader:shouldCorrect()
            itemsLoader.element:shouldDiscart()
            
            local data = { "armor", 5, "cavalo" }
            local items = itemsLoader:load(data)
            
            expect(match(items, { "armor", "cavalo" })).to.be.ok()
            expect(match(data, { "armor", "cavalo" })).to.be.ok()
        end)
        it("should correct converting miss elements", function()
            
            itemsLoader:shouldCorrect()
            itemsLoader.element:shouldDiscart()
            
            local data = { "armor", 5, "cavalo" }
            local items = itemsLoader:load(data)
            
            expect(match(items, { "armor", "5", "cavalo" })).to.be.ok()
            expect(match(data, { "armor", "5", "cavalo" })).to.be.ok()
        end)
    end)
end