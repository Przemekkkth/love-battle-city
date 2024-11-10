Entity = Object:extend()

function Entity:new(area, x, y, opts)
    self.type = SpriteType.ST_BONUS_GRENADE

    local opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.area = area
    self.x = x
    self.y = y
    self.sprite = spriteData[self.type][1]

    self.frameDisplayTime = 0
    self.currentFrame = 0

    self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )

    self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
   
    self.collider = world:newRectangleCollider(self.x, self.y, self.sprite.w, self.sprite.h)
    self.collider:setFixedRotation(true)
    if self.type == SpriteType.ST_STONE_WALL then
        self.collider:setType('static')
        self.collider:setCollisionClass('StoneWall')
    elseif self.type == SpriteType.ST_BUSH then
        self.collider:setType('static')
        self.collider:setCollisionClass('Bush')
    end
    self.collider:setObject(self)
end

function Entity:update(dt)
end

function Entity:draw()
    love.graphics.draw(Texture_IMG, self.quad, self.x, self.y)
end

function Entity:getPos()
    return {x = self.x, y = self.y}
end

function Entity:setPos(x, y)
    self.x = x
    self.y = y 
end

function Entity:getSize()
    return {x = self.sprite.w, y = self.sprite.h}
end