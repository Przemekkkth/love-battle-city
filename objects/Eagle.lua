Eagle = Entity:extend()

function Eagle:new(area, x, y, opts)
    Eagle.super.new(self, area, x, y, opts)
end

function Eagle:update(dt)
    if self.type == SpriteType.ST_DESTROY_EAGLE then
        self.animation:update(dt)
    else
        Eagle.super.update(self, dt)
    end
end

function Eagle:draw()
    if self.type == SpriteType.ST_DESTROY_EAGLE then
        self.animation:draw(Texture_IMG, self.x, self.y)
    else
        Eagle.super.draw(self)
    end
end

function Eagle:destroy()
    if self.type ~= SpriteType.ST_EAGLE then
        return 
    end

    self.type = SpriteType.ST_DESTROY_EAGLE
    self.sprite = spriteData[SpriteType.ST_DESTROY_EAGLE][1]

    self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )
    local x = self.sprite.x / self.sprite.w + 1
    self.animation = Anim8.newAnimation( self.grid(x, '1-7'), self.sprite.frameDuration, 'pauseAtEnd')
    local eagleSize = 32
    self.x = self.x - eagleSize / 2
    self.y = self.y - eagleSize / 2
    timer:after(7*self.sprite.frameDuration, function() 
        self.x = self.x + eagleSize / 2
        self.y = self.y + eagleSize / 2
        self.type = SpriteType.ST_FLAG
        self.sprite = spriteData[SpriteType.ST_FLAG][1]
        self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
    end)
end