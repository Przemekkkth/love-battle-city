Brick = Entity:extend()

function Brick:new(area, x, y, opts)
    Brick.super.new(self, area, x, y, opts)
    
    self.collisionCount = 0
    self.stateCode = 0
    self.collider:setType('static')
    self.collider:setRestitution(0.2) 
    self.collider:setCollisionClass('Brick')
    self.collider:setObject(self)
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

    self.collider:destroy()
    if self.stateCode == 1 then
        self.collider = world:newRectangleCollider(self.x, self.y, self.sprite.w, self.sprite.h / 2)
    elseif self.stateCode == 2 then
        self.collider = world:newRectangleCollider(self.x + self.sprite.w / 2, self.y, self.sprite.w / 2, self.sprite.h)
    elseif self.stateCode == 3 then
        self.collider = world:newRectangleCollider(self.x, self.y + self.sprite.h / 2, self.sprite.w, self.sprite.h / 2)
    elseif self.stateCode == 4 then
        self.collider = world:newRectangleCollider(self.x, self.y, self.sprite.w / 2, self.sprite.h)
    elseif self.stateCode == 5 then
        self.collider = world:newRectangleCollider(self.x + self.sprite.w / 2, self.y, self.sprite.w / 2, self.sprite.h / 2)
    elseif self.stateCode == 6 then
        self.collider = world:newRectangleCollider(self.x + self.sprite.w / 2, self.y + self.sprite.h / 2, self.sprite.w / 2, self.sprite.h / 2)
    elseif self.stateCode == 7 then
        self.collider = world:newRectangleCollider(self.x, self.y, self.sprite.w / 2, self.sprite.h / 2)
    elseif self.stateCode == 8 then
        self.collider = world:newRectangleCollider(self.x, self.y + self.sprite.h / 2, self.sprite.w / 2, self.sprite.h / 2)
    end

    if self.stateCode >= 1 and self.stateCode <= 8 then
        self.collider:setType('static')
        self.collider:setRestitution(0.2)
        self.collider:setCollisionClass('Brick')
        self.collider:setObject(self)
    end

    local smallBrickSize = 8 --smallest brick size
    if self.stateCode == 5 then
        self.quad = love.graphics.newQuad(self.sprite.x + 8, self.sprite.y + self.stateCode * self.sprite.h, smallBrickSize, smallBrickSize, Texture_IMG)
        local xPos, yPos = self.collider:getPosition()
        self.x = xPos - smallBrickSize / 2
        self.y = yPos - smallBrickSize / 2
    elseif self.stateCode == 6 then
        self.quad = love.graphics.newQuad(self.sprite.x + 8, self.sprite.y + self.stateCode * self.sprite.h + 8, smallBrickSize, smallBrickSize, Texture_IMG)
        local xPos, yPos = self.collider:getPosition()
        self.x = xPos - smallBrickSize / 2
        self.y = yPos - smallBrickSize / 2
    elseif self.stateCode == 8 then
        self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y + self.stateCode * self.sprite.h + 8, smallBrickSize, smallBrickSize, Texture_IMG)
        local xPos, yPos = self.collider:getPosition()
        self.x = xPos - smallBrickSize / 2
        self.y = yPos - smallBrickSize / 2
    elseif self.stateCode >= 1 and self.stateCode <= 9 then
        self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y + self.stateCode * self.sprite.h, self.sprite.w, self.sprite.h, Texture_IMG)
    end
end
