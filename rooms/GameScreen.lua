GameScreen = Object:extend()

function GameScreen:new()
    self.timer = Timer()
    world = wf.newWorld(0, 0, true)
    self:initCollisionClass() 
    self:initBoundary()

    self.area = Area(self)

    self.players = {}
    self.player1 = self.area:addGameObject('Player', PlayerStartingPoints[1][1], PlayerStartingPoints[1][2], {type = SpriteType.ST_PLAYER_1})
    self.player1:setLevel(Player1Data.level)
    if Player1Data.boat then 
        self.player1:setFlag(TankStateFlag.TSF_BOAT)
    end
    table.insert(self.players, self.player1)
    if GameData.mode == '2-Players' then
        self.player2 = self.area:addGameObject('Player', PlayerStartingPoints[2][1], PlayerStartingPoints[2][2], {type = SpriteType.ST_PLAYER_2})
        self.player2:setLevel(Player2Data.level)
        if Player2Data.boat then 
            self.player2:setFlag(TankStateFlag.TSF_BOAT)
        end
        table.insert(self.players, self.player2)
    end

    
    self.eagle = self.area:addGameObject('Eagle', 12*16, 384, {type = SpriteType.ST_EAGLE})

    self.tanks = {}
    self.enemyField = 1 -- 1-3
    self:generateEnemy()
    self:generateEnemy()
    self:generateEnemy()
    

    self.enemyStatisticsMarker = {}
    self.enemyToKill = 6
    self.player1Lives = Player1Data.lives
    self.player2Lives = Player2Data.lives
    for i = 0, self.enemyToKill-1 do
        table.insert(self.enemyStatisticsMarker, self.area:addGameObject('Entity', StatusRect.x + 8 + 16 * (i%2), 5 + 16 * math.floor(i / 2), {type = SpriteType.ST_LEFT_ENEMY}))
    end

    self.area:addGameObject('Entity', StatusRect.x + 5, 180, {type = SpriteType.ST_TANK_LIFE_LOGO})
    if GameData.mode == '2-Players' then
        self.area:addGameObject('Entity', StatusRect.x + 5, 200, {type = SpriteType.ST_TANK_LIFE_LOGO_1})  
    end
    self.area:addGameObject('Entity', StatusRect.x + 8, 220, {type = SpriteType.ST_STAGE_STATUS})

    self.isGameOver = false
    self.yGameOverText = 400
    self.bonuses = {}
    self.bushes = {}
    self:loadLevel('assets/levels/'..GameData.level)

    self.eagleWallData = {
        {x = 11, y = 25},
        {x = 11, y = 24},
        {x = 11, y = 23},
        {x = 12, y = 23},
        {x = 13, y = 23},
        {x = 14, y = 23},
        {x = 14, y = 24},
        {x = 14, y = 25},
    }
    self.eagleWall = {}
    
    self:genrateEagleWall()
end

function GameScreen:update(dt)
    self:checkCollisionBulletsWithTanks()
    self:checkCollisionPlayersWithBonuses()
    self:setEnemyTarget()
    self:checkEagle()
    self.area:update(dt)
    world:update(dt)
    self.timer:update(dt)

    self:checkEagleWall()
    self:checkBushes()
    self:handlePlayerInput()
end

function GameScreen:draw()
    self:drawStatisticsRect()
    self.area:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(Font3)
    love.graphics.print(self.player1Lives, StatusRect.x + 34, 183)
    if GameData.mode == '2-Players' then
        love.graphics.print(self.player2Lives, StatusRect.x + 34, 203)
    end
    love.graphics.setFont(Font2)
    love.graphics.print(GameData.level, StatusRect.x + 24, 242)
    love.graphics.setColor(1, 1, 1)
    self:drawBushes()

    if self.isGameOver then
        love.graphics.setFont(Font1)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print('Game Over', SCREEN_WIDTH / 2, self.yGameOverText, 0, 1, 1, love.graphics.getFont():getWidth('Game Over') / 2 )
        love.graphics.setColor(1, 1, 1)
    end

    --world:draw()
end

function GameScreen:loadLevel(path)
    m_level = {}
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
                self.area:addGameObject('Brick', x, y, {type = SpriteType.ST_BRICK_WALL})
            elseif char == "@" then
                self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_STONE_WALL})
            elseif char == "%" then
                table.insert(self.bushes, self.area:addGameObject('Entity', x, y, {type = SpriteType.ST_BUSH}) )
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
                    playerBullet:destroy()
                    if enemyObject:testFlag(TankStateFlag.TSF_BONUS) then
                        self:generateBonus()
                        enemyObject:clearFlag(TankStateFlag.TSF_BONUS)
                    end

                    if enemyObject:destroyTank() then
                        audio.crashSFX:play()
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
                            self:generateEnemy()
                        elseif self.enemyToKill == 0 then
                            self:goToNextLevel()
                        end
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
                    tankBullet:destroy()
                    if not playerObject:destroyTank() then
                        break
                    end
                    if GameData.mode == '1-Player' then
                        if playerObject.type == SpriteType.ST_PLAYER_1 then
                            self.player1Lives = self.player1Lives - 1
                            Player1Data.lives = self.player1Lives
                            if self.player1Lives > 0 then
                                self.timer:after(1, function() 
                                    self.player1 = self.area:addGameObject('Player', PlayerStartingPoints[1][1], PlayerStartingPoints[1][2], {type = SpriteType.ST_PLAYER_1})
                                    self.player1:setLevel(Player1Data.level)
                                    if Player1Data.boat then 
                                        self.player1:setFlag(TankStateFlag.TSF_BOAT)
                                    end
                                    table.insert(self.players, self.player1)
                                end)
                            else
                                self:setGameOver()
                            end
                            break
                        end
                    else 
                        if playerObject.type == SpriteType.ST_PLAYER_1 then
                            self.player1Lives = self.player1Lives - 1
                            Player1Data.lives = self.player1Lives
                            if self.player1Lives > 0 then
                                self.timer:after(1, function() 
                                    self.player1 = self.area:addGameObject('Player', PlayerStartingPoints[1][1], PlayerStartingPoints[1][2], {type = SpriteType.ST_PLAYER_1})
                                    self.player1:setLevel(Player1Data.level)
                                    if Player1Data.boat then 
                                        self.player1:setFlag(TankStateFlag.TSF_BOAT)
                                    end
                                    table.insert(self.players, self.player1)
                                end)
                            else
                                if self.player1Lives <= 0 and self.player2Lives <= 0 then
                                    self:setGameOver()
                                end
                            end
                            break
                        else
                            self.player2Lives = self.player2Lives - 1
                            Player2Data.lives = self.player2Lives
                            if self.player2Lives > 0 then
                                self.timer:after(1, function() 
                                    self.player2 = self.area:addGameObject('Player', PlayerStartingPoints[2][1], PlayerStartingPoints[2][2], {type = SpriteType.ST_PLAYER_2})
                                    self.player2:setLevel(Player2Data.level)
                                    if Player2Data.boat then 
                                        self.player2:setFlag(TankStateFlag.TSF_BOAT)
                                    end
                                    table.insert(self.players, self.player2)
                                end)
                            else
                                if self.player1Lives <= 0 and self.player2Lives <= 0 then
                                    self:setGameOver()
                                end
                            end
                            break                        
                        end
                    end 
                end
            end
        end
    end
end

function GameScreen:checkCollisionPlayersWithBonuses()
    for _, player in ipairs(self.players) do
        for _, bonus in ipairs(self.bonuses) do
            if player.collider:enter('Bonus') then
                local bonusCollider = player.collider:getEnterCollisionData('Bonus').collider
                local bonusObject   = bonusCollider:getObject()
                if bonusObject then
                    if bonusObject.type == SpriteType.ST_BONUS_GRENADE then
                        self:destroyAllEnemmies()
                        audio.bonusSFX:play()
                    elseif bonusObject.type == SpriteType.ST_BONUS_HELMET then
                        player:addShield()
                        audio.bonusSFX:play()
                    elseif bonusObject.type == SpriteType.ST_BONUS_CLOCK then
                        self:frozenAllEnemies()
                        audio.bonusSFX:play()
                        self.timer:after(TankFrozenTime, function() self:unfrozenAllEnemies() end)
                    elseif bonusObject.type == SpriteType.ST_BONUS_SHOVEL then
                        self:generateUpgradedEagleWall()
                        self.timer:after(ProtectEagleTime, function() self:genrateEagleWall() end)
                    elseif bonusObject.type == SpriteType.ST_BONUS_TANK then
                        if player.type == SpriteType.ST_PLAYER_1 then
                            self.player1Lives = self.player1Lives + 1
                            Player1Data.lives = self.player1Lives
                        elseif player.type == SpriteType.ST_PLAYER_2 then
                            self.player2Lives = self.player2Lives + 1
                            Player2Data.lives = self.player2Lives
                        end
                        audio.lifeSFX:play()
                    elseif bonusObject.type == SpriteType.ST_BONUS_STAR then
                        player:increaseLevel()
                        player:restartAnim()
                        audio.levelSFX:play()
                    elseif bonusObject.type == SpriteType.ST_BONUS_GUN then
                        player:increaseBulletCount()
                        audio.bonusSFX:play()
                    elseif bonusObject.type == SpriteType.ST_BONUS_BOAT then
                        player:setFlag(TankStateFlag.TSF_BOAT)
                        audio.bonusSFX:play()
                    end

                    bonusObject:destroy()
                    for i, bonus_ in ipairs(self.bonuses) do
                        if bonus_ == bonusObject then
                            table.remove(self.bonuses, i)
                            break
                        end
                    end
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
    world:addCollisionClass('Bonus', {ignores = {'Brick', 'PlayerBullet', 'EnemyBullet', 'Enemy', 'StoneWall'}})
    world:addCollisionClass('Bush', {ignores = {'Player', 'PlayerBullet', 'EnemyBullet', 'Enemy'}})
    world:addCollisionClass('Water', {ignores = {'PlayerBullet', 'EnemyBullet'}})
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
            self:setGameOver()
            return
        end
    end

    if self.eagle.collider:enter('PlayerBullet') then
        local playerBulletCollider = self.eagle.collider:getEnterCollisionData('PlayerBullet').collider
        local playerBulletObject   = playerBulletCollider:getObject()
        if playerBulletObject then
            playerBulletObject:destroy()
            self.eagle:destroy()
            self:setGameOver()
            return
        end
    end
end

function GameScreen:setGameOver()
    self.isGameOver = true
    self.timer:tween(2.5, self, {yGameOverText = 200}, 'in-out-quad')
    self.timer:after(3.0, function()  gotoRoom('MenuScreen') end)
end

function GameScreen:generateEnemy()
    local p = math.random() -- Generates a random float between 0 and 1
    local spriteType

    -- Determine the type of enemy based on the random number and current level
    if p < (0.00735 * currentLevel + 0.09265) then
        spriteType = SpriteType.ST_TANK_D
    else
        local randomType = {SpriteType.ST_TANK_A, SpriteType.ST_TANK_B, SpriteType.ST_TANK_C}
        spriteType = randomType[love.math.random(1, 3)]
    end

    local xPos = {EnemyStartingPoints[1][1], EnemyStartingPoints[2][1], EnemyStartingPoints[3][1]}

    local a, b, c
    if currentLevel <= 17 then
        a = -0.040625 * currentLevel + 0.940625
        b = -0.028125 * currentLevel + 0.978125
        c = -0.014375 * currentLevel + 0.994375
    else
        a = -0.012778 * currentLevel + 0.467222
        b = -0.025000 * currentLevel + 0.925000
        c = -0.036111 * currentLevel + 1.363889
    end

    -- Assign lives to the enemy based on probability
    p = math.random()
    local livesCount
    if p < a then
        livesCount = 1
    elseif p < b then
        livesCount = 2
    elseif p < c then
        livesCount = 3
    else
        livesCount = 4
    end    

    local enemy = self.area:addGameObject('Enemy', xPos[self.enemyField], 1, {type = spriteType, lives = livesCount})

    p = math.random()
    if p < 0.12 then
        enemy:setFlag(TankStateFlag.TSF_BONUS)
    end
    
    self.enemyField = self.enemyField + 1
    self.enemyField = (self.enemyField % 3) + 1
    table.insert(self.tanks, enemy)
end

function GameScreen:generateBonus()
    local spriteTypes = { SpriteType.ST_BONUS_GRENADE, SpriteType.ST_BONUS_HELMET, SpriteType.ST_BONUS_CLOCK, 
                          SpriteType.ST_BONUS_SHOVEL, SpriteType.ST_BONUS_TANK, SpriteType.ST_BONUS_STAR, 
                          SpriteType.ST_BONUS_GUN, SpriteType.ST_BONUS_BOAT}
    local bonusSize = 32
    local padding = 10
    local xPos = math.random(padding, MapRect.w - bonusSize - padding)
    local yPos = math.random(padding, MapRect.h - 2 * bonusSize - padding) -- 2* to avoid the eagle
    local spriteIdx = spriteTypes[math.random(1, 8)]
    table.insert(self.bonuses, self.area:addGameObject('Bonus', xPos, yPos, {type = spriteIdx}) )
end

function GameScreen:setEnemyTarget()
    local min_metric
    local metric 
    local target = {x = 0, y = 0}
    for _, tank in ipairs(self.tanks) do
        min_metric = 832
        if tank.type == SpriteType.ST_TANK_A or tank.type == SpriteType.ST_TANK_D then
            for _, player in ipairs(self.players) do
                if player.lives <= 0 then
                    break
                end
                local tankX, tankY     = tank.collider:getPosition()
                local playerX, playerY = player.collider:getPosition()
                metric = math.abs(playerX - tankX) + math.abs(playerY - tankY)
                if metric < min_metric then
                    min_metric = metric
                    local tankSize = 32
                    target = {x = playerX + tankSize / 2, y = playerY + tankSize / 2}
                end
            end
        end

        
        local eagleX, eagleY = self.eagle.collider:getPosition()
        local tankX, tankY   = tank.collider:getPosition()
        local eagleSize = 32
        metric = math.abs(eagleX - tankX) + math.abs(eagleY - tankY)
        if metric < min_metric then
            min_metric = metric
            target = {x = eagleX + eagleSize / 2, y = eagleY + eagleSize / 2}
        end

        tank.target = target
    end
end

function GameScreen:destroyAllEnemmies()
    for i = #self.tanks, 1, -1 do
        local enemyObject = self.tanks[i]
        enemyObject.lives = 1
        if enemyObject:destroyTank() then
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
                self:generateEnemy()
            elseif self.enemyToKill == 0 then
                self:goToNextLevel()
            end
        end
    end
end

function GameScreen:frozenAllEnemies()
    for i = #self.tanks, 1, -1 do
        self.tanks[i]:setFlag(TankStateFlag.TSF_FROZEN)
        self.tanks[i].collider:setLinearVelocity(0, 0)
    end
end

function GameScreen:unfrozenAllEnemies()
    for i = #self.tanks, 1, -1 do
        self.tanks[i]:clearFlag(TankStateFlag.TSF_FROZEN)
    end
end

function GameScreen:degenerateEagleWall()
    for i = #self.eagleWall, 1, -1 do
        if self.eagleWall[i].collider then
            self.eagleWall[i].collider:destroy()
        end
        self.eagleWall[i].toErase = true
        table.remove(self.eagleWall, i)
    end
    self.eagleWall = {}
end

function GameScreen:genrateEagleWall()
    self:degenerateEagleWall()
    for _, data in ipairs(self.eagleWallData) do
        local tileSize = 16
        local brick = self.area:addGameObject('Brick', data.x * tileSize, data.y * tileSize, {type = SpriteType.ST_BRICK_WALL})
        table.insert(self.eagleWall, brick)
    end
end

function GameScreen:generateUpgradedEagleWall()
    self:degenerateEagleWall()
    for _, data in ipairs(self.eagleWallData) do
        local tileSize = 16
        local brick = self.area:addGameObject('Entity', data.x * tileSize, data.y * tileSize, {type = SpriteType.ST_STONE_WALL})
        table.insert(self.eagleWall, brick)
    end
end

function GameScreen:goToNextLevel()
    Player1Data.lives = self.player1Lives
    Player1Data.level = self.player1.level
    Player1Data.boat = self.player1:testFlag(TankStateFlag.TSF_BOAT)
    if GameData.mode == '2-Players' then
        Player2Data.lives = self.player2Lives
        Player2Data.level = self.player2.level
        Player2Data.boat = self.player2:testFlag(TankStateFlag.TSF_BOAT)
    end
    GameData.level = GameData.level + 1
    if GameData.level >= 35 then
        GameData.level = 35
    end
    self.timer:after(2, function()  gotoRoom('StartScreen') end)
end

function GameScreen:goToPreviousLevel()
    Player1Data.lives = self.player1Lives
    Player1Data.level = self.player1.level
    Player1Data.boat = self.player1:testFlag(TankStateFlag.TSF_BOAT)
    if GameData.mode == '2-Players' then
        Player2Data.lives = self.player2Lives
        Player2Data.level = self.player2.level
        Player2Data.boat = self.player2:testFlag(TankStateFlag.TSF_BOAT)
    end
    GameData.level = GameData.level - 1
    if GameData.level <= 1 then
        GameData.level = 1
    end
    self.timer:after(2, function()  gotoRoom('StartScreen') end)
end

function GameScreen:handlePlayerInput()
    if input:released('goToNextLevel') then
        self:goToNextLevel()
    elseif input:released('goToPreviousLevel') then
        self:goToPreviousLevel()
    end
end

function GameScreen:drawBushes()
    for i = #self.bushes, 1, -1 do
        self.bushes[i]:draw()
    end
end

function GameScreen:checkBushes()
    for i = #self.bushes, 1, -1 do
        if self.bushes[i].toErase then
            table.remove(self.bushes, i)
        end
    end
end

function GameScreen:checkEagleWall()
    for i = #self.eagleWall, 1, -1 do
        if self.eagleWall[i].toErase then
            table.remove(self.eagleWall, i)
        end
    end
end