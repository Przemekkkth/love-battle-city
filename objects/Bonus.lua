Bonus = Entity:extend()

function Bonus:new(area, x, y, opts)
    Bonus.super.new(self, area, x, y, opts)
    self.show = true
    timer:every(BonusBlinkTime, function() self.show = not self.show  end)
    timer:after(BonusShowTime, function()   self.toErase = true end)
end

function Bonus:update(dt)

end

function Bonus:draw()
    if self.show then
        Bonus.super.draw(self)
    end
end