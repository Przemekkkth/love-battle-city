Brick = Entity:extend()

function Brick:new(area, x, y, opts)
    Brick.super.new(self, area, x, y, opts)
    
    self.collisionCount = 0
    self.stateCode = 0
    self.collider:setType('static')
    self.collider:setRestitution(0.2)
end

function Brick:bulletHit(_bulletDirection)
    self.collisionCount = self.collisionCount + 1
    if self.collisionCount == 1 then
        self.stateCode = _bulletDirection + 1
    elseif self.collisionCount == 2 then
        local sumSquare = (self.stateCode - 1) * (self.stateCode - 1) + _bulletDirection * _bulletDirection
        if sumSquare % 2 == 1 then
            self.stateCode = (sumSquare + 19.0) / 4.0
        else
            self.stateCode = 9
            self.toErase = true
        end
    else
        self.stateCode = 9
        self.toErase = true
    end

    if self.stateCode == 1 then
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 2 then
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h
    elseif self.stateCode == 3 then
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 4 then
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h
    elseif self.stateCode == 5 then
        self.x = self.x + self.sprite.w / 2
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 6 then
        self.x = self.x + self.sprite.w / 2
        self.y = self.y + self.sprite.h / 2
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 7 then
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 8 then
        self.y = self.y + self.sprite.h / 2
        self.collisionRect.x = self.x
        self.collisionRect.y = self.y
        self.collisionRect.w = self.sprite.w / 2
        self.collisionRect.h = self.sprite.h / 2
    elseif self.stateCode == 9 then
        self.x = -10
        self.y = -10
        self.collisionRect.w = 0
        self.collisionRect.h = 0
    end

    if self.stateCode >= 1 and self.stateCode <= 9 then
        self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y + self.stateCode * self.sprite.h, self.sprite.w, self.sprite.h, Texture_IMG)
    end
end