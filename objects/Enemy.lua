Enemy = Tank:extend()

function Enemy:new(area, x, y, opts)
    Enemy.super.new(self, area, x, y, opts)

    self.targetPosition = {x = 0, y = 0}
    self.direction = Direction.D_DOWN
    self.directionTime = 0
    self.keepDirectionTime = 1

    self.speedTime = 0
    self.tryToGoTime = 1

    self.fireTime = 0
    self.reloadTime = 1
    self.livesCount = 1
    self.bulletMaxSize = 2
    self.frozenTime = 0
    self.timer = Timer()
    self.collider:setCollisionClass('Enemy')
    self.collider:setObject(self)

    if self.type == SpriteType.ST_TANK_B then
        self.defaultSpeed = TankDefaultSpeed * 1.3
    else
        self.defaultSpeed = TankDefaultSpeed
    end

    self.timer:after(self.keepDirectionTime, function()  self:keepDirection() end)
    self.timer:after(self.tryToGoTime, function() self:tryToGo() end)
    self.timer:after(self.reloadTime, function() self:tryToShoot() end)

    self:respawn()
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)
    if self:testFlag(TankStateFlag.TSF_LIFE) then
        if self:testFlag(TankStateFlag.TSF_BONUS) then 

        end
    end
--[[
        if(testFlag(TSF_LIFE))
    {
        if(testFlag(TSF_BONUS))
            src_rect = moveRect(m_sprite->rect, (testFlag(TSF_ON_ICE) ? new_direction : direction) - 4, m_current_frame);
        else
            src_rect = moveRect(m_sprite->rect, (testFlag(TSF_ON_ICE) ? new_direction : direction) + (lives_count -1) * 4, m_current_frame);
    }
    else
        src_rect = moveRect(m_sprite->rect, 0, m_current_frame);

    if(testFlag(TSF_FROZEN)) return;
]]
    if self:testFlag(TankStateFlag.TSF_FROZEN) then
        return
    end

    self.timer:update(dt)
end

function Enemy:draw()
--[[    if(to_erase) return;
    if(AppConfig::show_enemy_target)
    {
        SDL_Color c;
        if(type == ST_TANK_A) c = {250, 0, 0, 250};
        if(type == ST_TANK_B) c = {0, 0, 250, 255};
        if(type == ST_TANK_C) c = {0, 255, 0, 250};
        if(type == ST_TANK_D) c = {250, 0, 255, 250};
        SDL_Rect r = {min(target_position.x, dest_rect.x + dest_rect.w / 2), dest_rect.y + dest_rect.h / 2, abs(target_position.x - (dest_rect.x + dest_rect.w / 2)), 1};
        Engine::getEngine().getRenderer()->drawRect(&r, c,  true);
        r = {target_position.x, min(target_position.y, dest_rect.y + dest_rect.h / 2), 1, abs(target_position.y - (dest_rect.y + dest_rect.h / 2))};
        Engine::getEngine().getRenderer()->drawRect(&r, c, true);
    }]]
    Enemy.super.draw(self)
end

function Enemy:scoreForHit()

end

function Enemy:keepDirection()
    self.keepDirectionTime = love.math.random(1, 3) 
    local p = math.random()
    if p < (self.type == SpriteType.ST_TANK_A and 0.8 or 0.5) and self.targetPosition.x > 0 and self.targetPosition.y > 0 then
        local dx = self.targetPosition.x - (self.x + self.collisionRect.w / 2)
        local dy = self.targetPosition.y - (self.y + self.collisionRect.h / 2)
        p = math.random()
        if math.abs(dx) > math.abs(dy) then
            -- Move horizontally
            self:setDirection(p < 0.7 and (dx < 0 and Direction.D_LEFT or Direction.D_RIGHT) or (dy < 0 and Direction.D_UP or Direction.D_DOWN))
        else
            -- Move vertically
            self:setDirection(p < 0.7 and (dy < 0 and Direction.D_UP or Direction.D_DOWN) or (dx < 0 and Direction.D_LEFT or Direction.D_RIGHT))
        end
    else
        -- Pick a random direction
        local directions = {Direction.D_UP, Direction.D_DOWN, Direction.D_LEFT, Direction.D_RIGHT}
        if self.y < SCREEN_HEIGHT / 2 then
            if self.x < 32 then
                local directions = {Direction.D_DOWN, Direction.D_RIGHT}
                self:setDirection(directions[math.random(1, 2)])
            elseif self.x > SCREEN_WIDTH - 32 - 10 then
                local directions = {Direction.D_DOWN, Direction.D_LEFT}
                self:setDirection(directions[math.random(1, 2)])
            else 
                self:setDirection(directions[math.random(2, 4)])
            end
        else
            self:setDirection(directions[math.random(1, 4)])
        end
        
    end

    self.timer:after(self.keepDirectionTime, function()  self:keepDirection() end)
end

function Enemy:tryToGo()
    self.tryToGoTime = love.math.random(1, 4.2) 
    self.speed = self.defaultSpeed
    self.timer:after(self.tryToGoTime, function() self:tryToGo() end)
end

function Enemy:tryToShoot()
    if self.type == SpriteType.ST_TANK_D then
        self.reloadTime = love.math.random(0.4, 0.6)
        local tankSize = 32
        local dx = self.targetPosition.x - (self.x + tankSize / 2)
        local dy = self.targetPosition.y - (self.y + tankSize / 2)

        self:fire()
            
        if math.random() < 0.5 then
            if self.direction == Direction.D_UP then
                if dy < 0 and math.abs(dx) < tankSize then
                    self:fire()
                end
            elseif self.direction == Direction.D_RIGHT then
                if dx > 0 and math.abs(dy) < tankSize then
                    self:fire()
                end
            elseif self.direction == Direction.D_DOWN then
                if dy > 0 and math.abs(dx) < tankSize then
                    self:fire()
                end
            elseif self.direction == Direction.D_left then
                if dx < 0 and math.abs(dy) < tankSize then
                    self:fire()
                end
            end
        end
    elseif self.type == SpriteType.ST_TANK_C then
        self.reloadTime = love.math.random(0.6, 0.8)
        self:fire()
    else
        self.reloadTime = love.math.random(0.8, 1)    
        self:fire()
    end
    self.stop = false
    self.timer:after(self.reloadTime, function() self:tryToShoot() end)
end