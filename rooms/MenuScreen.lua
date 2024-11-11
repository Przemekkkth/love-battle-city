MenuScreen = Object:extend()

function MenuScreen:new()
    self.logoImg = love.graphics.newQuad(0, 260, 406, 72, Texture_IMG)
    self.area = Area(self)
    self.tankPointer = self.area:addGameObject('Player', 0, 0, {type = SpriteType.ST_PLAYER_1, isMenu = true})
    self.tankPointer.pointer = true
    self.tankPointer:clearFlag(TankStateFlag.TSF_LIFE)
    self.tankPointer:setPos(144, 144)
    self.currentIndex = 0
end

function MenuScreen:update(dt)
    self.area:update(dt)
    if self.tankPointer:testFlag(TankStateFlag.TSF_CREATE) then
        return
    else
        self.tankPointer:clearFlag(TankStateFlag.TSF_CREATE)
        self.tankPointer:setFlag(TankStateFlag.TSF_MENU)
    end

    if input:pressed('up_arrow') then
        self.currentIndex = self.currentIndex - 1
        if self.currentIndex <= -1 then
            self.currentIndex = 2
        end
    elseif input:pressed('down_arrow') then
        self.currentIndex = self.currentIndex + 1
        if self.currentIndex >= 3 then
            self.currentIndex = 0
        end
    elseif input:pressed('enter') then
        if self.currentIndex == 2 then
            love.event.quit()
        elseif self.currentIndex == 0 then
            GameData.mode = '1-Player'
            gotoRoom('StartScreen')
            Player1Data.level = 0
            Player1Data.boat = false
            Player1Data.lives = 3
        elseif self.currentIndex == 1 then
            GameData.mode = '2-Players'
            gotoRoom('StartScreen')
            Player1Data.level = 0
            Player1Data.boat = false
            Player1Data.lives = 3
            Player2Data.level = 0
            Player2Data.boat = false
            Player2Data.lives = 3 
        end
    end

    if self.currentIndex == 0 then
        self.tankPointer:setPos(self.tankPointer.x, 144)
    elseif self.currentIndex == 1 then
        self.tankPointer:setPos(self.tankPointer.x, 174)
    elseif self.currentIndex == 2 then
        self.tankPointer:setPos(self.tankPointer.x, 206)
    end
    
end

function MenuScreen:draw()
    love.graphics.draw(Texture_IMG, self.logoImg, 29, 10)
    love.graphics.setFont(Font2)
    love.graphics.setColor(1,1,1)
    love.graphics.print('1 Player', 180, 152)
    love.graphics.print('2 Players', 180, 184)
    love.graphics.print('Exit', 180, 216)
    love.graphics.draw(LOGO_IMG, SCREEN_WIDTH / 2, 280, 0, 1, 1, LOGO_IMG:getWidth() / 2)
    self.area:draw()
end
