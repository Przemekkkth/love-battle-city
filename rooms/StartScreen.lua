StartScreen = Object:extend()

function StartScreen:new()
    self.text = "Stage "..GameData.level
    timer:after(2, function() gotoRoom('GameScreen') end)
    audio.startSFX:play()
end

function StartScreen:update(dt)
end

function StartScreen:draw()
    love.graphics.setFont(Font1)
    -- bg rgb color 110, 110, 110
    love.graphics.setColor(110/255, 110/255, 110/255)
    love.graphics.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.text, SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 1, 1, love.graphics.getFont():getWidth(self.text)/2, love.graphics.getFont():getHeight())
end
