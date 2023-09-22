return function()
    
    local match = require(script.Parent.Parent.utils).match
    local DataLoader = require(script.Parent.Parent)
    local newMapLoader = require(script.Parent)
    
    local mapLoader = newMapLoader(
        DataLoader.integer(),
        DataLoader.string("unknown")
    )
    
    it("should load data", function()
        
        local data = {
            { key = 1, value = "sword" },
            { key = 3, value = "apple" },
            { key = 10, value = "armor" },
        }
        local inventory = mapLoader:load(data)
        
        expect(match(inventory, {
            [1] = "sword",
            [3] = "apple",
            [10] = "armor"
        })).to.be.ok()
    end)
    
    describe("loading default data (:setDefaultData)", function()
        
        it("should load default data when miss pair", function()
            
            local data = {
                { key = 1, value = "sword" },
                { key = "maxItems", value = 5 },
                { key = 10, value = "armor" },
                { key = 15, value = 15 },
            }
            local inventory = mapLoader:load(data)
            
            expect(match(inventory, {})).to.be.ok()
        end)
        it("should load default data when miss data", function()
            
            local map = mapLoader:load("not a map")
            expect(match(map, {})).to.be.ok()
        end)
        it("shouldnt give same default data address", function()
            
            local defaultMap1 = mapLoader:load()
            local defaultMap2 = mapLoader:load()
            
            expect(defaultMap1).to.be.ok()
            expect(defaultMap2).to.be.ok()
            expect(defaultMap1).never.to.be.equal(defaultMap2)
        end)
    end)
    describe("discartions (:shouldDiscart)", function()
        
        it("should discart all if some miss pair", function()
            
            mapLoader:shouldDiscart()
            
            local data = {
                { key = 1, value = "sword" },
                { key = "maxItems", value = 5 },
                { key = 10, value = "armor" },
                { key = 15, value = 15 },
            }
            local inventory = mapLoader:load(data)
            
            expect(inventory).to.be.equal(nil)
        end)
        it("should discart when miss data", function()
            
            mapLoader:shouldDiscart()
            
            local map = mapLoader:load("not a map")
            expect(map).to.be.equal(nil)
        end)
    end)
    describe("corrections (:shouldCorrect)", function()
        
        it("should correct converting miss pairs", function()
            
            mapLoader:shouldCorrect()
            
            local data = {
                { key = 1, value = "sword" },
                { key = "2", value = true },
                { key = 10, value = "armor" },
            }
            local inventory = mapLoader:load(data)
            
            expect(match(inventory, {
                [1] = "sword",
                [2] = "true",
                [10] = "armor",
            })).to.be.ok()
            expect(match(data, {
                { key = 1, value = "sword" },
                { key = 2, value = "true" },
                { key = 10, value = "armor" },
            })).to.be.ok()
        end)
        it("should correct discarting miss pairs", function()
            
            mapLoader:shouldCorrect()
            mapLoader.pair:shouldDiscart()
            
            local data = {
                { key = 1, value = "sword" },
                { key = 10, value = "armor" },
                { key = "maxItems", value = 5 },
            }
            local inventory = mapLoader:load(data)
            
            expect(match(inventory, {
                [1] = "sword",
                [10] = "armor"
            })).to.be.ok()
            expect(match(data, {
                { key = 1, value = "sword" },
                { key = 10, value = "armor" },
            })).to.be.ok()
        end)
    end)
end