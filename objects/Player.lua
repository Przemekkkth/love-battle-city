Player = Tank:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    self.speed = 0
    self.livesCount = 11
    self.bulletMaxSize = PlayerBulletMaxSize
    self.score = 0
    self.shield = nil -- Entity(area, x, y, {type = SpriteType.ST_PLAYER_1} )
    self.pointer = false
    if self.isMenu == nil then 
        self.collider:setCollisionClass('Player')
        self.collider:setObject(self)
    end

    self.shieldAnim = Anim8.newAnimation( self.grid(31.5, '1-2'), 0.2 )
    if self.type == SpriteType.ST_PLAYER_1 then
        self.boatImg    = love.graphics.newQuad(29.5 * 32, 96, 32, 32, Texture_IMG)
    else
        self.boatImg    = love.graphics.newQuad(30.5 * 32, 96, 32, 32, Texture_IMG)
    end
    self.cooldown = 0.25 -- 250 ms
    self.shootTimer = 0
end

function Player:draw()
    Player.super.draw(self)
    if self:testFlag(TankStateFlag.TSF_BOAT) then
        local xPos, yPos = self.collider:getPosition()
        local tankSize = 32
        love.graphics.draw(Texture_IMG, self.boatImg, xPos - tankSize / 2, yPos - tankSize / 2)
    end
    if self:testFlag(TankStateFlag.TSF_SHIELD) then
        local xPos, yPos = self.collider:getPosition()
        local tankSize = 32
        self.shieldAnim:draw(Texture_IMG, xPos - tankSize / 2, yPos - tankSize / 2)
    end
end

function Player:update(dt)
    Player.super.update(self, dt)
    if not self:testFlag(TankStateFlag.TSF_MENU) and not self:testFlag(TankStateFlag.TSF_CREATE) and not self.pointer and not self.stop then
        local playerName = (self.type == SpriteType.ST_PLAYER_1) and 'player1' or 'player2'
        if input:down(playerName..'_up') then
            self:setDirection(Direction.D_UP)
            self.speed = self.defaultSpeed
        elseif input:down(playerName..'_left') then
            self:setDirection(Direction.D_LEFT)
            self.speed = self.defaultSpeed
        elseif input:down(playerName..'_right') then
            self:setDirection(Direction.D_RIGHT)
            self.speed = self.defaultSpeed
        elseif input:down(playerName..'_down') then
            self:setDirection(Direction.D_DOWN)
            self.speed = self.defaultSpeed
        else
            self.speed = 0.0;        
        end

        if input:down(playerName..'_fire') and self.shootTimer >= self.cooldown then 
            self:fire()
            self.shootTimer = 0
        end

        if self.speed > 0 then
            self.animation:update(dt)
        end
    elseif not self.stop then
        self.animation:update(dt)
    end

    if self:testFlag(TankStateFlag.TSF_SHIELD) then
        self.shieldAnim:update(dt)
    end

    self.shootTimer = self.shootTimer + dt
end

function Player:setDirection(_direction)
    Player.super.setDirection(self, _direction)
end

function Player:collide(_intersectRect, dt)
    Player.super.collide(self, _intersectRect, dt)
    if self.stop then 
        timer:after(0.4, function() self.stop = false end)
    end
end

function Player:bullets()
    Player.super.bullets(self)
end

function Player:addShield()
    self:setFlag(TankStateFlag.TSF_SHIELD)
    timer:after(TankShieldTime, function() self:clearFlag(TankStateFlag.TSF_SHIELD)  end)
end

function Player:destroyTank()
    if self:testFlag(TankStateFlag.TSF_SHIELD) then
        return false
    end
    if self:testFlag(TankStateFlag.TSF_BOAT) then
        self:clearFlag(TankStateFlag.TSF_BOAT) 
        return false
    end
    return Player.super.destroyTank(self)
end

function Player:increaseLevel()
    self.level = self.level + 1
    if self.level >= 3 then
        self.level = 3
        self.speed = 1.3 * self.speed
    end
    if self.level == 1 then
        self.speed = 1.1 * self.speed
    elseif self.level == 2 then
        self.speed = 1.2 * self.speed
        self:increaseBulletCount()
    end
end 

function Player:increaseBulletCount()
    -- max is 5
    self.bulletMaxSize = self.bulletMaxSize + 1
    if self.bulletMaxSize >= 5 then
        self.bulletMaxSize = 5
    end
end

function Player:restartAnim()
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

function Player:setLevel(level)
    if level == 1 then
        self:increaseLevel()
    elseif level == 2 then
        self:increaseLevel()
        self:increaseLevel()
    elseif level == 3 then
        self:increaseLevel()
        self:increaseLevel()
        self:increaseLevel()
    end
end