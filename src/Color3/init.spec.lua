return function()
    
    local match = require(script.Parent.Parent.utils).match
    local newColorLoader = require(script.Parent)
    
    local colorLoader = newColorLoader(Color3.new(0, 1, 0))
    
    it("should load RGB(2, 3, 4)", function()
        
        local data = { R = 2, G = 3, B = 4 }
        local color = colorLoader:load(data)
        
        expect(typeof(color)).to.be.equal("Color3")
        expect(color.R*255).to.be.near(data.R, .1)
        expect(color.G*255).to.be.near(data.G, .1)
        expect(color.B*255).to.be.near(data.B, .1)
    end)
    
    describe("loading default data (:setDefaultData)", function()
        
        it("should load default data when miss field", function()
            
            local data = { R = 255, G = nil, B = 0 }
            local color = colorLoader:load(data)
            
            expect(color).to.be.equal(Color3.new(0, 1, 0))
        end)
        it("should load default data when miss data", function()
            
            local color = colorLoader:load("not a color")
            
            expect(color).to.be.equal(Color3.new(0, 1, 0))
        end)
    end)
    describe("discartions (:shouldDiscart)", function()
        
        it("should discart when miss field", function()
            
            colorLoader:shouldDiscart()
            
            local data = { R = "255", G = 255, B = 0 }
            local color = colorLoader:load(data)
            
            expect(color).to.be.equal(nil)
        end)
        it("should discart when miss data", function()
            
            colorLoader:shouldDiscart()
            
            local color = colorLoader:load("not a color")
            expect(color).to.be.equal(nil)
        end)
    end)
    describe("corrections (:shouldCorrect)", function()
        
        it("should correct filling missing fields", function()
            
            colorLoader:shouldCorrect()
            
            local data = { R = 50, G = 255 }
            local color = colorLoader:load(data)
            
            expect(color).to.be.equal(Color3.fromRGB(50, 255, 0))
            expect(match(data, { R = 50, G = 255, B = 0 })).to.be.ok()
        end)
        it("should correct converting miss fields", function()
            
            colorLoader:shouldCorrect()
            
            local data = { R = "255", G = 50, B = 10 }
            local color = colorLoader:load(data)
            
            expect(color).to.be.equal(Color3.fromRGB(255, 50, 10))
            expect(match(data, {R = 255, G = 50, B = 10 })).to.be.ok()
        end)
    end)
end