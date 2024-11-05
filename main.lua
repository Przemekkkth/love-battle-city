Object = require 'libraries/Classic'
Input  = require 'libraries/Input'
Timer  = require 'libraries/Timer'
Anim8  = require 'libraries/Anim8'
wf = require 'libraries/windfield'
world = wf.newWorld(0, 0, true) 
require 'types'
require 'Spritesheet'
require 'Entity'
require 'objects/Tank' -- it is here because Player object uses Tank as parent

function love.load()
    Font1 = love.graphics.newFont('assets/font/prstartk.ttf', 28)
    Font2 = love.graphics.newFont('assets/font/prstartk.ttf', 14)
    Font3 = love.graphics.newFont('assets/font/prstartk.ttf', 10)

    currentLevel = 0
    isLeftHalfClicked = false
    tiles = {}
    holes = {}
    input = Input()
    timer = Timer()
    audio = {}
    audio.startSFX = love.audio.newSource('assets/sfx/startLevel.wav', 'static')
    audio.startSFX:setVolume(0.0)

    input:bind('left', 'left_arrow')
    input:bind('right', 'right_arrow')
    input:bind('up', 'up_arrow')
    input:bind('down', 'down_arrow')
    input:bind('mouse1', 'leftButton')
    input:bind('p', 'p')
    input:bind('backspace', 'backspace')
    input:bind('n', 'n')
    input:bind('escape', 'escape')
    input:bind('enter', 'enter')
    input:bind('space', 'fire')
    input:bind('e', 'enter')
    input:bind('return', 'enter')

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local object_files = {}
    recursiveEnumerate('rooms', object_files)
    requireFiles(object_files)

    current_room = nil
    gotoRoom('MenuScreen')
end

function love.update(dt)
    if current_room then 
        current_room:update(dt) 
    end

    timer:update(dt)
    if input:released('escape') then
        love.event.quit()
    end
 --[[   if input:released('escape') then 
        love.event.quit()
    elseif input:released('backspace') then
        gotoRoom('Menu')
    elseif input:released('n') then
        gotoRoom('GameScene')
    end]]
end

function love.draw()
    if current_room then
        current_room:draw() 
    end
end

-- Room --
function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end

-- Load --
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == "file" then
            table.insert(file_list, file)
        elseif fileInfo.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.translate(-x, -y)
end

function love.keypressed(key)
    if key == "c" then
        --love.graphics.captureScreenshot(os.time() .. ".png") -- uncomment if you want to make screenshot
    end
end