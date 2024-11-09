Bonus = Entity:extend()

function Bonus:new(area, x, y, opts)
    Bonus.super.new(self, area, x, y, opts)
    self.show = true
    self.blinkHandler = timer:every(BonusBlinkTime, function() self.show = not self.show  end)
    self.destroyHandler = timer:after(BonusShowTime, function()   self.collider:destroy() self.toErase = true end)
    self.collider:setCollisionClass('Bonus')
    self.collider:setType('static')
    self.collider:setObject(self)

end

function Bonus:update(dt)

end

function Bonus:draw()
    if self.show then
        Bonus.super.draw(self) 
    end
end

function Bonus:destroy()
    self.collider:destroy()
    self.toErase = true
    timer:cancel(self.blinkHandler)
    timer:cancel(self.destroyHandler)
end