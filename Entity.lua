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

    self.collisionRect = {}
    self.collisionRect.x = self.x
    self.collisionRect.y = self.y
    self.collisionRect.w = self.sprite.w
    self.collisionRect.h = self.sprite.h
    self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )

    self.quad = love.graphics.newQuad(self.sprite.x, self.sprite.y, self.sprite.w, self.sprite.h, Texture_IMG)
   
    self.collider = world:newRectangleCollider(self.x, self.y, self.sprite.w, self.sprite.h)
    self.collider:setFixedRotation(true)
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

function Entity:disableCollisionRect()
    self.collisionRect.w = 0
    self.collisionRect.h = 0
end

function Entity:enableCollisionRect()
    self.collisionRect.w = self.sprite.w
    self.collisionRect.h = self.sprite.h
end

function intersectRect(rect1, rect2)
    local intersect_rect = {
        x = math.max(rect1.x, rect2.x),
        y = math.max(rect1.y, rect2.y),
        w = math.min(rect1.x + rect1.w, rect2.x + rect2.w) - math.max(rect1.x, rect2.x),
        h = math.min(rect1.y + rect1.h, rect2.y + rect2.h) - math.max(rect1.y, rect2.y)
    }

    -- Check if there is an intersection
    if intersect_rect.w < 0 or intersect_rect.h < 0 then
        -- No intersection, return nil
        return nil
    end

    return intersect_rect
end
