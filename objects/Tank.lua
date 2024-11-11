Tank = Entity:extend()

function Tank:new(area, x, y, opts)
    self.lives = 1
    self.level = 0 -- this is only for Player
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
    self.bullets = {}
    self.collider:destroy()
    self.bulletMaxSize = 2
    
    self.tankWidth = self.sprite.w - 6
    self.tankHeight = self.sprite.h - 6
    self.collider = world:newRectangleCollider(self.x, self.y, self.tankWidth, self.tankHeight)
    self.collider:setFixedRotation(true)
    self:clearFlag(TankStateFlag.TSF_LIFE)
    
    if self.type == SpriteType.ST_TANK_A then
        
    elseif self.type == SpriteType.ST_TANK_B then
        self.speed = 1.4 * self.speed
    elseif self.type == SpriteType.ST_TANK_C then
        self.speed = 1.1 * self.speed
    elseif self.type == SpriteType.ST_TANK_D then
        self.speed = 0.9 * self.speed
        self.bulletMaxSize = 3
    end

    self:respawn()
end

function Tank:update(dt)
    if self:testFlag(TankStateFlag.TSF_LIFE) then
        if not self.stop and not self:testFlag(TankStateFlag.TSF_FROZEN) then
            if self.direction == Direction.D_UP then
                self.collider:setLinearVelocity(0, -self.speed)
            elseif self.direction == Direction.D_LEFT then
                self.collider:setLinearVelocity(-self.speed, 0)
            elseif self.direction == Direction.D_RIGHT then
                self.collider:setLinearVelocity(self.speed, 0)
            elseif self.direction == Direction.D_DOWN then
                self.collider:setLinearVelocity(0, self.speed)
           end

           if self.speed > 0 and not self:testFlag(TankStateFlag.TSF_FROZEN) then
                self.animation:update(dt)
           end
        end
    elseif self:testFlag(TankStateFlag.TSF_CREATE) or self:testFlag(TankStateFlag.TSF_DESTROYED) then
        self.animation:update(dt)
    end

    self:checkBulletLive()
end

function Tank:draw()
    if self:testFlag(TankStateFlag.TSF_MENU) or self:testFlag(TankStateFlag.TSF_CREATE) or self.isMenu then
        self.animation:draw(Texture_IMG, self.x, self.y)
    elseif self:testFlag(TankStateFlag.TSF_LIFE) then 
        local tankX, tankY = self.collider:getPosition()
        self.animation:draw(Texture_IMG, tankX - self.tankWidth / 2 - 3, tankY - self.tankHeight / 2 - 3)
    elseif self:testFlag(TankStateFlag.TSF_DESTROYED) then
        self.animation:draw(Texture_IMG, self.x, self.y)
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
    if self.direction == _direction then
        return
    end

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
        self.stop = false
        
        if self.type == SpriteType.ST_PLAYER_1 or self.type == SpriteType.ST_PLAYER_2 then
            self.animation = self:getAnim().up
            self:setDirection(Direction.D_UP)
            if not self.pointer then 
                self:addShield()
            end
        else
            self.animation = self:getAnim().down
            self:setDirection(Direction.D_DOWN)
            self.speed = self.defaultSpeed
        end

    end)
end

function Tank:getAnim()
    local xAnim
    if self:testFlag(TankStateFlag.TSF_BONUS) then
        xAnim = 1
    elseif self.lives == 1 then
        xAnim = 5
    elseif self.lives == 2 then
        xAnim = 9
    elseif self.lives == 3 then
        xAnim = 13
    elseif self.lives == 4 then
        xAnim = 17
    end

    if self.type == SpriteType.ST_PLAYER_1 then
        xAnim = 21
    elseif self.type == SpriteType.ST_PLAYER_2 then
        xAnim = 25
    end

    local yAnim = nil
    
    if self.type == SpriteType.ST_TANK_A then
        yAnim = '1-2'
    elseif self.type == SpriteType.ST_TANK_B then
        yAnim = '3-4'
    elseif self.type == SpriteType.ST_TANK_C then
        yAnim = '5-6'
    elseif self.type == SpriteType.ST_TANK_D then
        yAnim = '7-8'
    end

    if self.type == SpriteType.ST_PLAYER_1 or self.type == SpriteType.ST_PLAYER_2 then
        if self.level == 0 then
            yAnim = '1-2'
        elseif self.level == 1 then
            yAnim = '3-4'
        elseif self.level == 2 then
            yAnim = '5-6'
        elseif self.level == 3 then
            yAnim = '7-8'
        end
    end
    
    self.tankAnim = {up     = Anim8.newAnimation( self.grid(xAnim, yAnim), self.sprite.frameDuration ),
                    right  = Anim8.newAnimation( self.grid(xAnim + 1, yAnim), self.sprite.frameDuration ),
                    down   = Anim8.newAnimation( self.grid(xAnim + 2, yAnim), self.sprite.frameDuration ),
                    left   = Anim8.newAnimation( self.grid(xAnim + 3, yAnim), self.sprite.frameDuration ),
                    }
    return self.tankAnim
end

function Tank:fire()
    if not self:testFlag(TankStateFlag.TSF_LIFE) then 
        return
    end

    if #self.bullets < self.bulletMaxSize then
        audio.shootSFX:stop()
        audio.shootSFX:play()
        local tankDir = (self:testFlag(TankStateFlag.TSF_ON_ICE) and self.new_direction or self.direction)
        local xPos, yPos = self.collider:getPosition()

        local collisionClassName = nil
        if self.type == SpriteType.ST_PLAYER_1 or self.type == SpriteType.ST_PLAYER_2 then
            collisionClassName = 'PlayerBullet'
        else
            collisionClassName = 'EnemyBullet'
        end

        local bullet = nil --self.area:addGameObject('Bullet', xPos, yPos, {direction = tankDir, type = SpriteType.ST_BULLET})
        local tankSize = 32 -- px
        local bulletSize = 8
        if tankDir == Direction.D_UP then
            bullet = self.area:addGameObject('Bullet', xPos - bulletSize / 2, yPos - tankSize / 2 - bulletSize / 2, {direction = tankDir, type = SpriteType.ST_BULLET, collisionClass = collisionClassName})
        elseif tankDir == Direction.D_RIGHT then
            bullet = self.area:addGameObject('Bullet', xPos + tankSize / 2, yPos - bulletSize / 2, {direction = tankDir, type = SpriteType.ST_BULLET, collisionClass = collisionClassName})
        elseif tankDir == Direction.D_DOWN then
            bullet = self.area:addGameObject('Bullet', xPos - bulletSize / 2, yPos + tankSize / 2 - bulletSize / 2, {direction = tankDir, type = SpriteType.ST_BULLET, collisionClass = collisionClassName})
        elseif tankDir == Direction.D_LEFT then
            bullet = self.area:addGameObject('Bullet', xPos - tankSize / 2 - bulletSize / 2, yPos - bulletSize / 2, {direction = tankDir, type = SpriteType.ST_BULLET, collisionClass = collisionClassName})
        end

        if self.type == SpriteType.ST_PLAYER_1 or self.type == SpriteType.ST_PLAYER_2 then
            if self.level == 1 then
                bullet.speed = 1.1 * bullet.speed
            elseif self.level == 2 then
                bullet.speed = 1.2 * bullet.speed
            elseif self.level == 3 then
                bullet.speed = 1.3 * bullet.speed
            end
        elseif self.type == SpriteType.ST_TANK_B then 
            bullet.speed = 1.1 * bullet.speed
        elseif self.type == SpriteType.ST_TANK_C or self.type == SpriteType.ST_TANK_D then
            bullet.speed = 1.2 * bullet.speed 
        end

        table.insert(self.bullets, bullet)
    end
end

function Tank:checkBulletLive()
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        if bullet.toErase then
            table.remove(self.bullets, i)
        end
    end
end 

function Tank:destroyTank()
    if not self:testFlag(TankStateFlag.TSF_LIFE) then
        return false
    end

    self:clearFlag(TankStateFlag.TSF_BONUS) 
    self.lives = self.lives - 1
    if self.lives <= 0 then
        local tankSize = 32
        self.stop = true
        self:clearFlag(TankStateFlag.TSF_LIFE)
        self:setFlag(TankStateFlag.TSF_DESTROYED)
        self.speed = 0
        self.sprite = spriteData[SpriteType.ST_DESTROY_TANK][1]
        self.x, self.y = self.collider:getPosition()
        self.x = self.x - tankSize 
        self.y = self.y - tankSize 
        self.collider:destroy()
    
        self.grid = Anim8.newGrid( self.sprite.w, self.sprite.h, Texture_IMG:getWidth(), Texture_IMG:getHeight() )
        local x = self.sprite.x / self.sprite.w + 1
        self.animation = Anim8.newAnimation( self.grid(x, '1-6'), self.sprite.frameDuration, 'pauseAtEnd')
        timer:after(7*self.sprite.frameDuration, function() 
            self.toErase = true 
        end)
        for i = #self.bullets, 1, -1 do
            self.bullets[i]:destroy()
            table.remove(self.bullets, i)
        end
        audio.crashSFX:stop()
        audio.crashSFX:play()
        return true
    else
        if self.direction == Direction.D_UP then
            self.animation = self:getAnim().up
        elseif self.direction == Direction.D_RIGHT then
            self.animation = self:getAnim().right
        elseif self.direction == Direction.D_DOWN then
            self.animation = self:getAnim().down
        elseif self.direction == Direction.D_LEFT then
            self.animation = self:getAnim().left
        end
        return false
    end
end
