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
end

function Player:draw()
    Player.super.draw(self)
    if self:testFlag(TankStateFlag.TSF_SHIELD) then
        local xPos, yPos = self.collider:getPosition()
        local tankSize = 32
        self.shieldAnim:draw(Texture_IMG, xPos - tankSize / 2, yPos - tankSize / 2)
    end
end

function Player:update(dt)
    Player.super.update(self, dt)
    if not self:testFlag(TankStateFlag.TSF_MENU) and not self:testFlag(TankStateFlag.TSF_CREATE) and not self.pointer and not self.stop then
        if input:down('up_arrow') then
            self:setDirection(Direction.D_UP)
            self.speed = self.defaultSpeed
        elseif input:down('left_arrow') then
            self:setDirection(Direction.D_LEFT)
            self.speed = self.defaultSpeed
        elseif input:down('right_arrow') then
            self:setDirection(Direction.D_RIGHT)
            self.speed = self.defaultSpeed
        elseif input:down('down_arrow') then
            self:setDirection(Direction.D_DOWN)
            self.speed = self.defaultSpeed
        else
            self.speed = 0.0;        
        end

        if input:down('fire', 0.0, 0.25) then 
            self:fire()
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
    return Player.super.destroyTank(self)
end