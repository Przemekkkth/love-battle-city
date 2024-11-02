Bullet = Entity:extend()

function Bullet:new(area, x, y, opts)
    Bullet.super.new(self, area, x, y, opts)

    self.speed = BulletDefaultSpeed
    self.increasedDamage = false
    self.collide = false
    self.animation = self.upAnimation

    if self.direction == Direction.D_UP then
        self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
    elseif self.direction == Direction.D_RIGHT then
        self.quad = love.graphics.newQuad(self.sprite.x + self.sprite.w, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
    elseif self.direction == Direction.D_DOWN then
        self.quad = love.graphics.newQuad(self.sprite.x + 2*self.sprite.w, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
    elseif self.direction == Direction.D_LEFT then
        self.quad = love.graphics.newQuad(self.sprite.x + 3*self.sprite.w, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
    end
end

function Bullet:update(dt)
    if not self.collide then
        if self.direction == Direction.D_UP then
            self.y = self.y - (self.speed * dt)
        elseif self.direction == Direction.D_RIGHT then
            self.x = self.x + (self.speed * dt)
        elseif self.direction == Direction.D_DOWN then
            self.y = self.y + (self.speed * dt)
        elseif self.direction == Direction.D_LEFT then
            self.x = self.x - (self.speed * dt)
        end

        local bulletSize = 8
        if self.y <= 0 then
            self:destroy()
        elseif self.x <= 0 then
            self:destroy()
        elseif self.y >= SCREEN_HEIGHT - bulletSize then
            self:destroy()
        elseif self.x >= SCREEN_WIDTH - StatusRect.w - bulletSize then
            self:destroy()
        end
    else
        self.animation:update(dt)
    end
end

function Bullet:draw()
    if not self.collide then
        Bullet.super.draw(self)
    else
        self.animation:draw(Texture_IMG, self.x, self.y)
    end
end

function Bullet:destroy()
    --TO DO
    if self.collide then
        return
    end

    self.collide = true
    self.speed = 0
    self.sprite = spriteData[SpriteType.ST_DESTROY_BULLET][1]

    self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )
    local x = self.sprite.x / self.sprite.w + 1
    local y = self.sprite.y / self.sprite.h + 1
    self.animation = Anim8.newAnimation( self.grid(x, '1-5'), self.sprite.frameDuration, 'pauseAtEnd')
    timer:after(5*self.sprite.frameDuration, function() self.toErase = true end)

    self.collisionRect.x = 0
    self.collisionRect.y = 0
    self.collisionRect.w = 0
    self.collisionRect.h = 0

    local bulletSize = 8
    if self.direction == Direction.D_UP then
        self.x = self.x + (bulletSize - self.sprite.w) / 2
        self.y = self.y - self.sprite.w / 2
    elseif self.direction == Direction.D_RIGHT then
        self.x = self.x + bulletSize - self.sprite.w / 2
        self.y = self.y + (bulletSize - self.sprite.h) / 2
    elseif self.direction == Direction.D_DOWN then
        self.x = self.x + (bulletSize - self.sprite.w) / 2
        self.y = self.y + bulletSize - self.sprite.h / 2
    elseif self.direction == Direction.D_LEFT then
        self.x = self.x - self.sprite.w / 2
        self.y = self.y + (bulletSize - self.sprite.h) / 2
    end
end

function Bullet:setDirection(_direction)
    if _direction == Direction.D_UP then
        self.direction = _direction
        self.animation = self.upAnimation
    elseif _direction == Direction.D_RIGHT then
        self.direction = _direction
        self.animation = self.rightAnimation
    elseif _direction == Direction.D_DOWN then
        self.direction = _direction
        self.animation = self.downAnimation
    elseif _direction == Direction.D_LEFT then
        self.direction = _direction
        self.animation = self.leftAnimation
    end
end