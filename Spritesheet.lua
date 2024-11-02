Texture_IMG = love.graphics.newImage('assets/sprite/texture.png')

spriteData = {}

local function insert(type, x, y, w, h, frameCount, frameDuration, loop)
    spriteData[type] = {}
    local data = {}
    data.x = x 
    data.y = y
    data.w = w
    data.h = h
    --data.tex = love.graphics.newQuad(x, y, w, h, Texture_IMG)
    data.frameCount = frameCount
    data.frameDuration = frameDuration / 1000
    data.loop = loop
    table.insert(spriteData[type], data)
end


insert(SpriteType.ST_TANK_A, 128, 0, 32, 32, 2, 100, true);
insert(SpriteType.ST_TANK_B, 128, 64, 32, 32, 2, 100, true);
insert(SpriteType.ST_TANK_C, 128, 128, 32, 32, 2, 100, true);
insert(SpriteType.ST_TANK_D, 128, 192, 32, 32, 2, 100, true);

insert(SpriteType.ST_PLAYER_1, 640, 0, 32, 32, 2, 50, true);
insert(SpriteType.ST_PLAYER_2, 768, 0, 32, 32, 2, 50, true);

insert(SpriteType.ST_BRICK_WALL, 928, 0, 16, 16, 1, 200, false);
insert(SpriteType.ST_STONE_WALL, 928, 144, 16, 16, 1, 200, false);
insert(SpriteType.ST_WATER, 928, 160, 16, 16, 2, 350, true);
insert(SpriteType.ST_BUSH, 928, 192, 16, 16, 1, 200, false);
insert(SpriteType.ST_ICE, 928, 208, 16, 16, 1, 200, false);

insert(SpriteType.ST_BONUS_GRENADE, 896, 0, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_HELMET, 896, 32, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_CLOCK, 896, 64, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_SHOVEL, 896, 96, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_TANK, 896, 128, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_STAR, 896, 160, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_GUN, 896, 192, 32, 32, 1, 200, false);
insert(SpriteType.ST_BONUS_BOAT, 896, 224, 32, 32, 1, 200, false);

insert(SpriteType.ST_SHIELD, 976, 0, 32, 32, 2, 45, true);
insert(SpriteType.ST_CREATE, 1008, 0, 32, 32, 10, 100, false);
insert(SpriteType.ST_DESTROY_TANK, 1152, 0, 64, 64, 7, 70, false);
insert(SpriteType.ST_DESTROY_BULLET, 1120, 0, 32, 32, 5, 40, false);
insert(SpriteType.ST_BOAT_P1, 944, 96, 32, 32, 1, 200, false);
insert(SpriteType.ST_BOAT_P2, 976, 96, 32, 32, 1, 200, false);

insert(SpriteType.ST_EAGLE, 944, 0, 32, 32, 1, 200, false);
insert(SpriteType.ST_DESTROY_EAGLE, 1040, 0, 64, 64, 7, 100, false);
insert(SpriteType.ST_FLAG, 944, 32, 32, 32, 1, 200, false);
insert(SpriteType.ST_TANK_LIFE_LOGO, 944, 64, 16, 16, 1, 200, false);

insert(SpriteType.ST_BULLET, 944, 128, 8, 8, 1, 200, false);

insert(SpriteType.ST_LEFT_ENEMY, 944, 144, 16, 16, 1, 200, false);
insert(SpriteType.ST_STAGE_STATUS, 976, 64, 32, 32, 1, 200, false);

--insert(SpriteType.ST_TANKS_LOGO, 0, 260, 406, 72, 1, 200, false);