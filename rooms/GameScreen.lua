GameScreen = Object:extend()

function GameScreen:new()
    world = wf.newWorld(0, 0, true)
    self:initCollisionClass() 
    self:initBoundary()

    self.area = Area(self)
    self.player = self.area:addGameObject('Player', 128, 384, {type = SpriteType.ST_PLAYER_1})
    self.players = {}
    table.insert(self.players, self.player)
    local eagle = self.area:addGameObject('Eagle', 12*16, 384, {type = SpriteType.ST_EAGLE})

    self.tanks = {}
    table.insert(self.tanks, self.area:addGameObject('Enemy', 1, 1, {type = SpriteType.ST_TANK_A}))
    table.insert(self.tanks, self.area:addGameObject('Enemy', 192, 1, {type = SpriteType.ST_TANK_B}))
    table.insert(self.tanks, self.area:addGameObject('Enemy', 384, 1, {type = SpriteType.ST_TANK_C}))

    self.enemyStatisticsMarker = {}
    self.enemyToKill = 6
    self.playerLives = 1
    for i = 0, self.enemyToKill-1 do
        table.insert(self.enemyStatisticsMarker, self.area:addGameObject('Entity', StatusRect.x + 8 + 16 * (i%2), 5 + 16 * math.floor(i / 2), {type = SpriteType.ST_LEFT_ENEMY}))
    end

    self.area:addGameObject('Entity', StatusRect.x + 5, 180, {type = SpriteType.ST_TANK_LIFE_LOGO})
    self.area:addGameObject('Entity', StatusRect.x + 8, 220, {type = SpriteType.ST_STAGE_STATUS})

    self.isGameOver = false
    self.yGameOverText = 400
    self:loadLevel('assets/levels/1')
end

function GameScreen:update(dt)
    self:checkCollisionPlayerWithStaticBodies(dt)
    self:checkCollisionBulletsWithStaticBodies()
    self:checkPlayersWithTanks(dt)
    self:checkCollisionPlayerBulletsWithEnemyBullets()
    self:checkCollisionBulletsWithTanks()
    self.area:update(dt)
    world:update(dt)
end

function GameScreen:draw()
    self:drawStatisticsRect()
    self.area:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(Font3)
    love.graphics.print(self.playerLives, StatusRect.x + 34, 183)
    love.graphics.setFont(Font2)
    love.graphics.print(self.playerLives, StatusRect.x + 24, 242)
    love.graphics.setColor(1, 1, 1)
    if self.isGameOver then
        love.graphics.setFont(Font1)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print('Game Over', SCREEN_WIDTH / 2, self.yGameOverText, 0, 1, 1, love.graphics.getFont():getWidth('Game Over') / 2 )
        love.graphics.setColor(1, 1, 1)
    end
    world:draw()
end

function GameScreen:loadLevel(path)
    m_level = {}
    staticBodies = {}
    local file = love.filesystem.read(path)
    local j = -1

    for line in file:gmatch("[^\r\n]+") do
        j = j + 1
        local row = {}
        for i = 1, #line do
            local tileSize = 16
            local char = line:sub(i, i)
            local obj = nil
            local x = (i - 1) * tileSize
            local y = j * tileSize

            if char == "#" then
                obj = self.area:addGameObject('Brick', x, y, {type = SpriteType.ST_BRICK_WALL})
                table.insert(staticBodies, obj)
            elseif char == "@" then
                table.insert(staticBodies, self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_STONE_WALL}) )
            elseif char == "%" then
                self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_BUSH})
            elseif char == "~" then
                self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_WATER})
            elseif char == "-" then
                self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_ICE})
            end
        end
    end
end

function GameScreen:checkCollisionPlayerWithStaticBodies(dt)
    for k, v in ipairs(staticBodies) do
        self.player:collide(v, dt)
        for _, tank in ipairs(self.tanks) do
            tank:collide(v, dt)
        end
    end
end

function GameScreen:checkCollisionBulletsWithStaticBodies()
    for key = #staticBodies, 1, -1 do  
        local staticBody = staticBodies[key]
        for idx, bullet in ipairs(self.player.bullets) do
            self:checkCollisionBulletWithStaticBody(bullet, staticBody)
        end

        for _, tank in ipairs(self.tanks) do
            for _, bullet in ipairs(tank.bullets) do
                self:checkCollisionBulletWithStaticBody(bullet, staticBody)
            end
        end
    end
end

function GameScreen:checkCollisionBulletWithStaticBody(bullet, staticBody)
    local staticRect = {
        x = math.floor(staticBody.x),
        y = math.floor(staticBody.y),
        w = math.floor(staticBody.collisionRect.w),
        h = math.floor(staticBody.collisionRect.h)
    }
    local bulletRect = {
        x = math.floor(bullet.x),
        y = math.floor(bullet.y),
        w = math.floor(bullet.collisionRect.w),
        h = math.floor(bullet.collisionRect.h)
    }

    local isCollidingX = (staticRect.x <= bulletRect.x + bulletRect.w) and (staticRect.x + staticRect.w >= bulletRect.x)
    local isCollidingY = (staticRect.y <= bulletRect.y + bulletRect.h) and (staticRect.y + staticRect.h >= bulletRect.y)

    local isBrick = staticBody.type == SpriteType.ST_BRICK_WALL
    local isWall  = staticBody.type == SpriteType.ST_STONE_WALL

    if isCollidingX and isCollidingY and isBrick then
        staticBody:bulletHit(bullet.direction)
        bullet:destroy()
    elseif isCollidingX and isCollidingY and isWall then
        if bullet.speed >= 1.3 * BulletDefaultSpeed then
            staticBody.toErase = true
            table.remove(staticBodies, key) 
        end
        bullet:destroy()
    end
end

function GameScreen:checkPlayersWithTanks(dt)
    for _, player in ipairs(self.players) do
        for _, tank in ipairs(self.tanks) do
            
            local playerRect = {
                x = math.floor(player.x),
                y = math.floor(player.y), 
                w = math.floor(player.collisionRect.w), 
                h = math.floor(player.collisionRect.h)
            }

            local tankRect = {
                x = math.floor(tank.x),
                y = math.floor(tank.y), 
                w = math.floor(tank.collisionRect.w), 
                h = math.floor(tank.collisionRect.h)
            }

            local isCollidingX = (playerRect.x <= tankRect.x + tankRect.w) and (playerRect.x + playerRect.w >= tankRect.x)
            local isCollidingY = (playerRect.y <= tankRect.y + tankRect.h) and (playerRect.y + playerRect.h >= tankRect.y)
            if isCollidingX and isCollidingY then
                if tank.direction == Direction.D_UP then
                    tank.y = tank.y + tank.speed * dt + 0.1
                    tank.stop = true
                elseif tank.direction == Direction.D_DOWN then
                    tank.y = tank.y - tank.speed * dt - 0.1
                    tank.stop = true
                elseif tank.direction == Direction.D_LEFT then
                    tank.x = tank.x + tank.speed * dt + 0.1
                    tank.stop = true
                elseif tank.direction == Direction.D_RIGHT then
                    tank.x = tank.x - tank.speed * dt - 0.1
                    tank.stop = true
                end

                if player.direction == Direction.D_UP then
                    player.y = player.y + player.speed * dt + 0.1
                    player.stop = true
                elseif player.direction == Direction.D_DOWN then
                    player.y = player.y - player.speed * dt - 0.1
                    player.stop = true
                elseif player.direction == Direction.D_LEFT then
                    player.x = player.x + player.speed * dt + 0.1
                    player.stop = true
                elseif player.direction == Direction.D_RIGHT then
                    player.x = player.x - player.speed * dt - 0.1
                    player.stop = true
                end
            end
        end
    end
end

function GameScreen:checkCollisionPlayerBulletsWithEnemyBullets()
    for _, player in ipairs(self.players) do
        for _, tank in ipairs(self.tanks) do
            for _, playerBullet in ipairs(player.bullets) do
                for _, tankBullet in ipairs(tank.bullets) do
                    local playerBulletRect = {
                        x = math.floor(playerBullet.x),
                        y = math.floor(playerBullet.y), 
                        w = math.floor(playerBullet.collisionRect.w), 
                        h = math.floor(playerBullet.collisionRect.h)
                    }
        
                    local tankBulletRect = {
                        x = math.floor(tankBullet.x),
                        y = math.floor(tankBullet.y), 
                        w = math.floor(tankBullet.collisionRect.w), 
                        h = math.floor(tankBullet.collisionRect.h)
                    }
        
                    local isCollidingX = (playerBulletRect.x <= tankBulletRect.x + tankBulletRect.w) and (playerBulletRect.x + playerBulletRect.w >= tankBulletRect.x)
                    local isCollidingY = (playerBulletRect.y <= tankBulletRect.y + tankBulletRect.h) and (playerBulletRect.y + playerBulletRect.h >= tankBulletRect.y)

                    if isCollidingX and isCollidingY then
                        playerBullet:destroy()
                        tankBullet:destroy()
                    end
                end 
            end
        end
    end
end

function GameScreen:checkCollisionBulletsWithTanks()
    for _, player in ipairs(self.players) do
        for _, playerBullet in ipairs(player.bullets) do 
            for i = #self.tanks, 1, -1 do 
                local tank = self.tanks[i]
    
                local playerBulletRect = {
                    x = math.floor(playerBullet.x),
                    y = math.floor(playerBullet.y), 
                    w = math.floor(playerBullet.collisionRect.w), 
                    h = math.floor(playerBullet.collisionRect.h)
                }
    
                local tankRect = {
                    x = math.floor(tank.x),
                    y = math.floor(tank.y), 
                    w = math.floor(tank.collisionRect.w), 
                    h = math.floor(tank.collisionRect.h)
                }
    
                local isCollidingX = (playerBulletRect.x <= tankRect.x + tankRect.w) and (playerBulletRect.x + playerBulletRect.w >= tankRect.x)
                local isCollidingY = (playerBulletRect.y <= tankRect.y + tankRect.h) and (playerBulletRect.y + playerBulletRect.h >= tankRect.y)
    
                if isCollidingX and isCollidingY then
                    tank:destroyTank()
                    table.remove(self.tanks, i) 
                    playerBullet:destroy()
                    self.enemyToKill = self.enemyToKill - 1
                    self.enemyStatisticsMarker[#self.enemyStatisticsMarker].toErase = true
                    table.remove(self.enemyStatisticsMarker, #self.enemyStatisticsMarker)
                    if self.enemyToKill > 0 and #self.tanks < self.enemyToKill then
                        timer:after(0.1, function() 
                            local xPos = {1, 192, 384}
                            local type = {SpriteType.ST_TANK_A, SpriteType.ST_TANK_B, SpriteType.ST_TANK_C, SpriteType.ST_TANK_D}
                            table.insert(self.tanks, self.area:addGameObject('Enemy', xPos[love.math.random(1, 3)], 1, {type = SpriteType.ST_TANK_A}))    
                            end)
                    elseif self.enemyToKill == 0 then
                        timer:after(2, function()  gotoRoom('StartScreen') end)
                    end
                    break 
                end
            end
        end
    end
    
    for _, tank in ipairs(self.tanks) do
        for _, tankBullet in ipairs(tank.bullets) do 
            for i = #self.players, 1, -1 do 
                local player = self.players[i]
    
                local tankBulletRect = {
                    x = math.floor(tankBullet.x),
                    y = math.floor(tankBullet.y), 
                    w = math.floor(tankBullet.collisionRect.w), 
                    h = math.floor(tankBullet.collisionRect.h)
                }
    
                local playerRect = {
                    x = math.floor(player.x),
                    y = math.floor(player.y), 
                    w = math.floor(player.collisionRect.w), 
                    h = math.floor(player.collisionRect.h)
                }
    
                local isCollidingX = (tankBulletRect.x <= playerRect.x + playerRect.w) and (tankBulletRect.x + tankBulletRect.w >= playerRect.x)
                local isCollidingY = (tankBulletRect.y <= playerRect.y + playerRect.h) and (tankBulletRect.y + tankBulletRect.h >= playerRect.y)
    
                if isCollidingX and isCollidingY then
                    player:destroyTank() 
                    tankBullet:destroy()
                    self.playerLives = self.playerLives - 1
                    if self.playerLives > 0 then
                        timer:after(1, function() 
                            self.player = self.area:addGameObject('Player', 128, 384, {type = SpriteType.ST_PLAYER_1})
                            table.insert(self.players, self.player)
                        end)
                    else
                        self.isGameOver = true
                        timer:tween(2.5, self, {yGameOverText = 200}, 'in-out-quad')
                        timer:after(3.0, function()  gotoRoom('MenuScreen') end)
                    end
                    break 
                end
            end
        end
    end
end

function GameScreen:drawStatisticsRect()
    love.graphics.setColor(110/255, 110/255, 110/255)
    love.graphics.rectangle('fill', StatusRect.x, StatusRect.y, StatusRect.w, StatusRect.h )
    love.graphics.setColor(1, 1, 1)
end

function GameScreen:initCollisionClass()
    world:addCollisionClass('Boundary')
    world:addCollisionClass('Brick')
end

function GameScreen:initBoundary()
    self.topBoundary = world:newRectangleCollider(0, -1, SCREEN_WIDTH, 1)
    self.topBoundary:setType('static')
    self.topBoundary:setCollisionClass('Boundary')
    self.leftBoundary = world:newRectangleCollider(-1, 0, 1, SCREEN_HEIGHT)
    self.leftBoundary:setType('static')
    self.bottomBoundary = world:newRectangleCollider(0, SCREEN_HEIGHT, SCREEN_WIDTH, 1)
    self.bottomBoundary:setType('static')
    self.rightBoundary = world:newRectangleCollider(StatusRect.x, 0, 1, SCREEN_HEIGHT)
    self.rightBoundary:setType('static')
end