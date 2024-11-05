Tank = Entity:extend()

function Tank:new(area, x, y, opts)
    Tank.super.new(self, area, x, y, opts)

    self.area = area
    self.direction = Direction.D_UP
    self.slipTime  = 0
    self.defaultSpeed = TankDefaultSpeed
    self.speed = TankDefaultSpeed
    self.shield = nil
    self.boat = nil
    self.shieldTime = 0
    self.frozenTime = 0
    self.flags = {}
    self.stop = false
    self.level = 0
    self.bullets = {}
    self.collider:destroy()
    self.tankWidth = self.sprite.w - 6
    self.tankHeight = self.sprite.h - 6
    self.collider = world:newRectangleCollider(self.x, self.y, self.tankWidth, self.tankHeight)
    self.collider:setFixedRotation(true)
    self:clearFlag(TankStateFlag.TSF_LIFE)

    
    local xAnim
    if self.type == SpriteType.ST_TANK_A then 
        xAnim = 1
        self.level = love.math.random(0, 3)
    elseif self.type == SpriteType.ST_TANK_B then 
        xAnim = 5
        self.level = love.math.random(0, 3)
    elseif self.type == SpriteType.ST_TANK_C then 
        xAnim = 9
        self.level = love.math.random(0, 3)
    elseif self.type == SpriteType.ST_TANK_D then 
        xAnim = 13
        self.level = love.math.random(0, 3)
    elseif self.type == SpriteType.ST_TANK_B then 
        xAnim = 17
        self.level = love.math.random(0, 3)
    elseif self.type == SpriteType.ST_PLAYER_1 then 
        xAnim = 21
    elseif self.type == SpriteType.ST_PLAYER_2 then 
        xAnim = 25
    end
    
    local y = self.sprite.y / 32 + 1

    self.type0Anim = {up     = Anim8.newAnimation( self.grid(xAnim, '1-2'), self.sprite.frameDuration ),
                      right  = Anim8.newAnimation( self.grid(xAnim + 1, '1-2'), self.sprite.frameDuration ),
                      down   = Anim8.newAnimation( self.grid(xAnim + 2, '1-2'), self.sprite.frameDuration ),
                      left   = Anim8.newAnimation( self.grid(xAnim + 3, '1-2'), self.sprite.frameDuration ),
                     }

    self.type1Anim = {up     = Anim8.newAnimation( self.grid(xAnim, '3-4'), self.sprite.frameDuration ),
                      right  = Anim8.newAnimation( self.grid(xAnim + 1, '3-4'), self.sprite.frameDuration ),
                      down   = Anim8.newAnimation( self.grid(xAnim + 2, '3-4'), self.sprite.frameDuration ),
                      left   = Anim8.newAnimation( self.grid(xAnim + 3, '3-4'), self.sprite.frameDuration ),
                     }
    self.type2Anim = {up     = Anim8.newAnimation( self.grid(xAnim, '5-6'), self.sprite.frameDuration ),
                     right  = Anim8.newAnimation( self.grid(xAnim + 1, '5-6'), self.sprite.frameDuration ),
                     down   = Anim8.newAnimation( self.grid(xAnim + 2, '5-6'), self.sprite.frameDuration ),
                     left   = Anim8.newAnimation( self.grid(xAnim + 3, '5-6'), self.sprite.frameDuration ),
                    }
    self.type3Anim = {up     = Anim8.newAnimation( self.grid(xAnim, '7-8'), self.sprite.frameDuration ),
                    right  = Anim8.newAnimation( self.grid(xAnim + 1, '7-8'), self.sprite.frameDuration ),
                    down   = Anim8.newAnimation( self.grid(xAnim + 2, '7-8'), self.sprite.frameDuration ),
                    left   = Anim8.newAnimation( self.grid(xAnim + 3, '7-8'), self.sprite.frameDuration ),
                   }   
    
    self:respawn()     
end

function Tank:update(dt)
    if self:testFlag(TankStateFlag.TSF_LIFE) then
        if not self.stop and not self:testFlag(TankStateFlag.TSF_FROZEN) then
            if self.direction == Direction.D_UP then
                --self.y = self.y - self.speed * dt
                self.collider:setLinearVelocity(0, -self.speed)
            elseif self.direction == Direction.D_LEFT then
                --self.x = self.x - self.speed * dt
                self.collider:setLinearVelocity(-self.speed, 0)
            elseif self.direction == Direction.D_RIGHT then
                self.collider:setLinearVelocity(self.speed, 0)
            elseif self.direction == Direction.D_DOWN then
                self.collider:setLinearVelocity(0, self.speed)
           end

           if self.speed > 0 then
            self.animation:update(dt)
           end
        end
    elseif self:testFlag(TankStateFlag.TSF_CREATE) or self:testFlag(TankStateFlag.TSF_DESTROYED) then
        self.animation:update(dt)
    end

    self:checkBulletLive()
    self:clamp()
end

function Tank:draw()
    local tankX, tankY = self.collider:getPosition()
    if self:testFlag(TankStateFlag.TSF_MENU) or self:testFlag(TankStateFlag.TSF_CREATE) or self.isMenu then
        self.animation:draw(Texture_IMG, self.x, self.y)
    elseif self:testFlag(TankStateFlag.TSF_LIFE) then 
        self.animation:draw(Texture_IMG, tankX - self.tankWidth / 2 - 3, tankY - self.tankHeight / 2 - 3)
    end
end

function Tank:clearFlag(flag)
    self.flags[flag] = nil
end

function Tank:testFlag(flag)
    return self.flags[flag]
end

function Tank:setFlag(flag)
    if not self:testFlag(flag) and flag == TankStateFlag.TSF_ON_ICE then
        self.new_direction = self.direction
    end
    
    if flag == TankStateFlag.TSF_SHIELD then
        if self.m_shield == nil then
            --self.m_shield = { pos_x = self.pos_x, pos_y = self.pos_y, type = "ST_SHIELD" }
        end
        self.m_shield_time = 0
    end

    if flag == TankStateFlag.TSF_BOAT then
        if self.m_boat == nil then
            --local boatType = (self.type == "ST_PLAYER_1") and "ST_BOAT_P1" or "ST_BOAT_P2"
            --self.m_boat = { pos_x = self.pos_x, pos_y = self.pos_y, type = boatType }
        end
    end

    if flag == TankStateFlag.TSF_FROZEN then
        self.m_frozen_time = 0
    end

    if flag == TankStateFlag.TSF_MENU then
        self:setDirection(Direction.D_RIGHT)
    end

    self.flags[flag] = true
end

function Tank:setDirection(_direction)

    self.direction = _direction
    if not self:testFlag(TankStateFlag.TSF_LIFE) or self:testFlag(TankStateFlag.TSF_CREATE) then
        return
    end

    if self:testFlag(TankStateFlag.TSF_ON_ICE) then
        self.newDirection = _direction
        if self.speed ~= 0 or self.slipTime == 0.0 then
            self.direction = _direction
        end

        if (self.slipTime ~= 0 and self.direction == self.newDirection) or self.slipTime == 0 then
            self.slipTime = SlipTime
        end
    else
        self.direction = _direction
    end

    local tile_rect = {w = 32, h = 32}  -- Define your tile dimensions here, for example, 32x32
    local epsilon = 5

    if self.direction == Direction.D_UP then
        self.animation = self:getAnim().up
    elseif self.direction == Direction.D_RIGHT then
        self.animation = self:getAnim().right
    elseif self.direction == Direction.D_DOWN then
        self.animation = self:getAnim().down
    elseif self.direction == Direction.D_LEFT then
        self.animation = self:getAnim().left
    end
end

function Tank:respawn()
    self.speed = 0
    self.stop  = true
    self.slipTime = 0

    self:clearFlag(TankStateFlag.TSF_SHIELD)
    self:clearFlag(TankStateFlag.TSF_BOAT)
    self:setFlag(TankStateFlag.TSF_CREATE)

    self.sprite = spriteData[SpriteType.ST_CREATE][1]

    local x = self.sprite.x / self.sprite.w + 1
    self.animation = Anim8.newAnimation( self.grid(x, '1-10'), self.sprite.frameDuration )
    timer:after(10*self.sprite.frameDuration, function()
        self:clearFlag(TankStateFlag.TSF_CREATE)
        self:setFlag(TankStateFlag.TSF_LIFE)
        self:enableCollisionRect()
        self.stop = false
        
        if self.type == SpriteType.ST_PLAYER_1 or self.type == SpriteType.ST_PLAYER_2 then
            self.animation = self:getAnim().up
            self:setDirection(Direction.D_UP)
        else
            self.animation = self:getAnim().down
            self:setDirection(Direction.D_DOWN)
            self.speed = self.defaultSpeed
        end

    end)

    self:disableCollisionRect()
end

function Tank:getAnim()
    if self.level == 0 then
        return self.type0Anim
    elseif self.level == 1 then
        return self.type1Anim
    elseif self.level == 2 then
        return self.type2Anim
    elseif self.level == 3 then
        return self.type3Anim
    end
end

function Tank:fire()
    if not self:testFlag(TankStateFlag.TSF_LIFE) then 
        return
    end

    if #self.bullets < self.bulletMaxSize then
        local tankDir = (self:testFlag(TankStateFlag.TSF_ON_ICE) and self.new_direction or self.direction)
        local bullet = self.area:addGameObject('Bullet', self.x, self.y, {direction = tankDir, type = SpriteType.ST_BULLET})
        local tankSize = 32 -- px
        local bulletSize = 8
        if tankDir == Direction.D_UP then
            bullet:setPos(bullet.x + tankSize / 2 - bulletSize / 2, bullet.y)
        elseif tankDir == Direction.D_RIGHT then
            bullet:setPos(bullet.x + tankSize - bulletSize / 2, bullet.y + tankSize / 2 - bulletSize / 2)
        elseif tankDir == Direction.D_DOWN then
            bullet:setPos(bullet.x + tankSize / 2 - bulletSize / 2, bullet.y + tankSize - bulletSize / 2)
        elseif tankDir == Direction.D_LEFT then
            bullet:setPos(bullet.x, bullet.y + tankSize / 2 - bulletSize / 2)
        end
        table.insert(self.bullets, bullet)
    end

    --[[if(!testFlag(TSF_LIFE)) return nullptr;
    if(bullets.size() < m_bullet_max_size)
    {
        //podajemy początkową dowolną pozycję, bo nie znamy wymiarów pocisku
        Bullet* bullet = new Bullet(pos_x, pos_y);
        bullets.push_back(bullet);

        Direction tmp_d = (testFlag(TSF_ON_ICE) ? new_direction : direction);
        switch(tmp_d)
        {
        case D_UP:
            bullet->pos_x += (dest_rect.w - bullet->dest_rect.w) / 2;
            bullet->pos_y -= bullet->dest_rect.h - 4;
            break;
        case D_RIGHT:
            bullet->pos_x += dest_rect.w - 4;
            bullet->pos_y += (dest_rect.h - bullet->dest_rect.h) / 2;
            break;
        case D_DOWN:
            bullet->pos_x += (dest_rect.w - bullet->dest_rect.w) / 2;
            bullet->pos_y += dest_rect.h - 4;
            break;
        case D_LEFT:
            bullet->pos_x -= bullet->dest_rect.w - 4;
            bullet->pos_y += (dest_rect.h - bullet->dest_rect.h) / 2;
            break;
        }

        bullet->direction = tmp_d;
        if(type == ST_TANK_C)
            bullet->speed = AppConfig::bullet_default_speed * 1.3;
        else
            bullet->speed = AppConfig::bullet_default_speed;

        bullet->update(0); //zmiana pozycji dest_rect
        return bullet;
    }
    return nullptr;]]
end

function Tank:checkBulletLive()
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        if bullet.toErase then
            table.remove(self.bullets, i)
        end
    end
end 

function Tank:clampX()
    local tankSize = 32
    if self.x <= 0 then
        self.x = 0
    elseif self.x + tankSize >= SCREEN_WIDTH - StatusRect.w then
        self.x = SCREEN_WIDTH - StatusRect.w - tankSize
    end

    local tankX, tankY = self.collider:getPosition()
    if tankX < 0 and not self.stop then 
        local tankVX, tankVY = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(0, tankVY)
        self.stop = true
    end
end

function Tank:clampY()
    local tankSize = 32
    if self.y <= 0 then
        self.y = 0
    elseif self.y + tankSize >= SCREEN_HEIGHT then
        self.y = SCREEN_HEIGHT - tankSize
    end

    --local tankX, tankY = self.collider:getPosition()
    

end

function Tank:clamp()
    self:clampX()
    self:clampY()
end

function Tank:collide(_intersectRect, dt)
    --
    local tankRect = {x = math.floor(self.x+2), y = math.floor(self.y+2), w = 32-4, h = 32-4}
    local otherRect = {x = math.floor(_intersectRect.collisionRect.x), y = math.floor(_intersectRect.collisionRect.y), w = math.floor(_intersectRect.collisionRect.w), h = math.floor(_intersectRect.collisionRect.h)}

    -- AABB
    local isCollidingX = (tankRect.x < otherRect.x + otherRect.w) and (tankRect.x + tankRect.w > otherRect.x)
    local isCollidingY = (tankRect.y < otherRect.y + otherRect.h) and (tankRect.y + tankRect.h > otherRect.y)

    if isCollidingX and isCollidingY then
        if (self.direction == Direction.D_UP and otherRect.y < tankRect.y) then
            self.stop = true
            self.slipTime = 0
            self.y = self.y + self.speed*dt + 0.1
        elseif (self.direction == Direction.D_DOWN and otherRect.y + otherRect.h > tankRect.y + tankRect.h) then
            self.stop = true
            self.slipTime = 0
            self.y = self.y - self.speed*dt - 0.1
        elseif (self.direction == Direction.D_LEFT and otherRect.x < tankRect.x) then
            self.stop = true
            self.slipTime = 0
            self.x = self.x + self.speed*dt + 0.1
        elseif (self.direction == Direction.D_RIGHT and otherRect.x + otherRect.w > tankRect.x + tankRect.w) then
            self.stop = true
            self.slipTime = 0
            self.x = self.x - self.speed*dt - 0.1
        end
    end
end

function Tank:bullets()
    return self.bullets
end

function Tank:destroyTank()
    if not self:testFlag(TankStateFlag.TSF_LIFE) then
        return
    end 

    self.stop = true
    self:clearFlag(TankStateFlag.TSF_LIFE)
    self:setFlag(TankStateFlag.TSF_DESTROYED)
    self.speed = 0
    self.sprite = spriteData[SpriteType.ST_DESTROY_TANK][1]
    self.y = self.y - 16
    self.x = self.x - 16
    self.collisionRect.w = 0
    self.collisionRect.h = 0

    self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )
    local x = self.sprite.x / self.sprite.w + 1
    self.animation = Anim8.newAnimation( self.grid(x, '1-6'), self.sprite.frameDuration, 'pauseAtEnd')
    timer:after(7*self.sprite.frameDuration, function() self.toErase = true end)
end