local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local game = require("game")

local level = {}

level.complete = false
level.x = 48
level.y = 27
level.name = "Main Menu"

level.noUI = true
level.track_id = 8 -- random if not set

local x_offset, y_offset = 0, 0
local drawbox_x, drawbox_y = 0, 0
local pan_x, pan_y = -1, -1
local texture_scale = 1
local tile_size

local wait = 0
local flag = false

function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  drawbox_x, drawbox_y, texture_scale = grid.setOffset(0,0,5)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos[,options])
	grid.set(TYPE_MIRROR, 5, 5, {rotation=1, state=2, color=COLOR_MAGENTA})
	grid.set(TYPE_MIRROR, 8, 5, {rotation=0, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 10, 9, {rotation=1, state=2, color=COLOR_GREEN})
	grid.set(TYPE_MIRROR, 13, 8, {rotation=1, state=2, color=COLOR_RED})
	grid.set(TYPE_MIRROR, 15, 9, {rotation=1, state=2, color=COLOR_RED})
	grid.set(TYPE_MIRROR, 10, 19, {rotation=0, state=2, color=COLOR_BLUE})
	grid.set(TYPE_MIRROR, 15, 19, {rotation=0, state=2, color=COLOR_GREEN})
	grid.set(TYPE_MIRROR, 5, 23, {rotation=0, state=2, color=COLOR_GREEN})
	grid.set(TYPE_MIRROR, 8, 25, {rotation=0, state=2, color=COLOR_RED})
	grid.set(TYPE_MIRROR, 17, 25, {rotation=1, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 25, 4, {rotation=1, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 36, 4, {rotation=0, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 35, 9, {rotation=0, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 40, 8, {rotation=0, state=2, color=COLOR_WHITE})
	grid.set(TYPE_MIRROR, 40, 14, {rotation=0, state=2, color=COLOR_WHITE})
	--grid.set(TYPE_MIRROR, 40, 19, {rotation=1, state=2, color=COLOR_WHITE})
	
	grid.set(TYPE_PWHEEL, 5, 9, {rotation=0, state=2, color=COLOR_RED})
	grid.set(TYPE_PWHEEL, 17, 12, {rotation=1, state=2, color=COLOR_YELLOW})
	grid.set(TYPE_PWHEEL, 44, 6, {rotation=0, state=2, color=COLOR_CYAN})
	grid.set(TYPE_PWHEEL, 31, 22, {rotation=1, state=2, color=COLOR_BLUE})
	grid.set(TYPE_PWHEEL, 44, 25, {rotation=1, state=2, color=COLOR_GREEN})
	
	grid.set(TYPE_DELAY, 10, 14, {delay=1, state=1, color=COLOR_BLUE})
	grid.set(TYPE_DELAY, 15, 14, {delay=1, state=1, color=COLOR_GREEN})
	grid.set(TYPE_DELAY, 20, 14, {delay=1, state=4, color=COLOR_BLACK})
	grid.set(TYPE_DELAY, 35, 14, {delay=60, state=3, color=COLOR_BLACK})
	grid.set(TYPE_DELAY, 28, 25, {delay=1, state=3, color=COLOR_RED})
	
	grid.set(TYPE_SOURCE, 13, 4, {state=2, rotation=2, color=COLOR_GREEN})
	grid.set(TYPE_SOURCE, 40, 12, {state=2, color=COLOR_RED})
	grid.set(TYPE_SOURCE, 20, 24, {state=2, color=COLOR_YELLOW})
	grid.set(TYPE_SOURCE, 35, 24, {state=2, color=COLOR_GREEN})
	
	grid.set(TYPE_LOGIC,17,19,{state = LOGIC_OR}):setSides("out","out","out","in")
	grid.set(TYPE_LOGIC,20,19,{state = LOGIC_OR}):setSides("out","out","in","in")
	grid.set(TYPE_LOGIC,25,19,{state = LOGIC_AND}):setSides("out","in",nil,"in")
	grid.set(TYPE_LOGIC,35,19,{state = LOGIC_OR}):setSides("out","in","in","out")
	grid.set(TYPE_LOGIC,10,12,{state = LOGIC_OR}):setSides("in",nil,"out","out")
	grid.set(TYPE_LOGIC,20,9,{state = LOGIC_NOT}):setSides(nil,"in",nil,"out")
	grid.set(TYPE_LOGIC,25,9,{state = LOGIC_NOT}):setSides("out","out","in","out")
	grid.set(TYPE_LOGIC,30,9,{state = LOGIC_AND}):setSides(nil,"out","in","in")
	grid.set(TYPE_LOGIC,17,23,{state = LOGIC_OR}):setSides("in",nil,"in","out")
	grid.set(TYPE_LOGIC,44,22,{state = LOGIC_NOT}):setSides("in","out","out","out")
	grid.set(TYPE_LOGIC,36,6,{state = LOGIC_OR}):setSides("in","out","out",nil)
	grid.set(TYPE_LOGIC,30,14,{state = LOGIC_OR}):setSides("out","in",nil,"in")
	
	grid.set(TYPE_RECEIVER, 36, 9, {color=COLOR_RED})
	grid.set(TYPE_RECEIVER, 39, 12, {rotation=3, color=COLOR_YELLOW}):setSides(nil,nil,"activate",nil)
	
	wait = game_time
end

function level.update(dt)
  x_offset, y_offset = x_offset + dt*pan_x, y_offset + dt*pan_y
  tile_size = grid.getTileSize()
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  if width > (level.x - 2*x_offset)*tile_size then
    x_offset = level.x - width/tile_size - x_offset
    pan_x = -1 + (0.5*math.random()-0.25)
  elseif level.x + 2*x_offset < width/tile_size then
    x_offset = width/tile_size - level.x - x_offset
    pan_x = 1 + (0.5*math.random()-0.25)
  end
  if height > (level.y - 2*y_offset)*tile_size then
    y_offset = level.y - height/tile_size - y_offset
    pan_y = -1 + (0.5*math.random()-0.25)
  elseif level.y + 2*y_offset < height/tile_size then
    y_offset = height/tile_size - level.y - y_offset
    pan_y = 1 + (0.5*math.random()-0.25)
  end
  drawbox_x, drawbox_y, texture_scale = grid.setOffset(x_offset, y_offset, 5)
  
	if flag == false and game_time > wait + 1.2 then
		flag = true
		grid.set(TYPE_MIRROR, 40, 19, {rotation=1, state=2, color=COLOR_WHITE})
	end
end

return level