GameScreen = Object:extend()

function GameScreen:new()
    world = wf.newWorld(0, 0, true)
    self:initCollisionClass() 
    self:initBoundary()

    self.area = Area(self)
    self.player = self.area:addGameObject('Player', PlayerStartingPoints[1][1], PlayerStartingPoints[1][2], {type = SpriteType.ST_PLAYER_1})
    self.players = {}
    table.insert(self.players, self.player)
    self.eagle = self.area:addGameObject('Eagle', 12*16, 384, {type = SpriteType.ST_EAGLE})

    self.tanks = {}
    table.insert(self.tanks, self.area:addGameObject('Enemy', EnemyStartingPoints[1][1], EnemyStartingPoints[1][2], {type = SpriteType.ST_TANK_A}))
    table.insert(self.tanks, self.area:addGameObject('Enemy', EnemyStartingPoints[2][1], EnemyStartingPoints[2][2], {type = SpriteType.ST_TANK_B}))
    table.insert(self.tanks, self.area:addGameObject('Enemy', EnemyStartingPoints[3][1], EnemyStartingPoints[3][2], {type = SpriteType.ST_TANK_C}))

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
    self:checkCollisionBulletsWithTanks()
    self:checkEagle()
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

function GameScreen:checkCollisionBulletsWithTanks()
    for _, player in ipairs(self.players) do
        for _, playerBullet in ipairs(player.bullets) do
            if playerBullet.collider:enter('Enemy') then
                local enemyCollider = playerBullet.collider:getEnterCollisionData('Enemy').collider
                local enemyObject   = enemyCollider:getObject()
                if enemyObject then 
                    enemyObject:destroyTank()
                    playerBullet:destroy()
                    self.enemyToKill = self.enemyToKill - 1
                    self.enemyStatisticsMarker[#self.enemyStatisticsMarker].toErase = true
                    table.remove(self.enemyStatisticsMarker, #self.enemyStatisticsMarker)
                    
                    for i, tank in ipairs(self.tanks) do
                        if tank == enemyObject then
                            table.remove(self.tanks, i)
                            break
                        end
                    end

                    if self.enemyToKill > 0 and #self.tanks < self.enemyToKill then
                        timer:after(0.1, function() 
                            local xPos = {EnemyStartingPoints[1][1], EnemyStartingPoints[2][1], EnemyStartingPoints[3][1]}
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
            if tankBullet.collider:enter('Player') then
                local playerCollider = tankBullet.collider:getEnterCollisionData('Player').collider
                local playerObject   = playerCollider:getObject()
                if playerObject then 
                    playerObject:destroyTank() 
                    tankBullet:destroy()
                    self.playerLives = self.playerLives - 1
                    if self.playerLives > 0 then
                        timer:after(1, function() 
                            self.player = self.area:addGameObject('Player', PlayerStartingPoints[1][1], PlayerStartingPoints[2][1], {type = SpriteType.ST_PLAYER_1})
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
    world:addCollisionClass('PlayerBullet')
    world:addCollisionClass('EnemyBullet')
    world:addCollisionClass('Eagle')
    world:addCollisionClass('Player', {ignores = {'PlayerBullet'}})
    world:addCollisionClass('Enemy', {ignores = {'EnemyBullet'}})
    world:addCollisionClass('StoneWall')
end

function GameScreen:initBoundary()
    self.topBoundary = world:newRectangleCollider(0, -1, SCREEN_WIDTH, 1)
    self.topBoundary:setType('static')
    self.topBoundary:setCollisionClass('Boundary')

    self.leftBoundary = world:newRectangleCollider(-1, 0, 1, SCREEN_HEIGHT)
    self.leftBoundary:setType('static')
    self.leftBoundary:setCollisionClass('Boundary')

    self.bottomBoundary = world:newRectangleCollider(0, SCREEN_HEIGHT, SCREEN_WIDTH, 1)
    self.bottomBoundary:setType('static')
    self.bottomBoundary:setCollisionClass('Boundary')

    self.rightBoundary = world:newRectangleCollider(StatusRect.x, 0, 10, SCREEN_HEIGHT)
    self.rightBoundary:setType('static')
    self.rightBoundary:setCollisionClass('Boundary')
end

function GameScreen:checkEagle()
    if self.eagle.collider:enter('EnemyBullet') then
        local enemyBulletCollider = self.eagle.collider:getEnterCollisionData('EnemyBullet').collider
        local enemyBulletObject   = enemyBulletCollider:getObject()
        if enemyBulletObject then
            enemyBulletObject:destroy()
            self.eagle:destroy()
            return
        end
    end

    if self.eagle.collider:enter('PlayerBullet') then
        local playerBulletCollider = self.eagle.collider:getEnterCollisionData('PlayerBullet').collider
        local playerBulletObject   = playerBulletCollider:getObject()
        if playerBulletObject then
            playerBulletObject:destroy()
            self.eagle:destroy()
            return
        end
    end
end