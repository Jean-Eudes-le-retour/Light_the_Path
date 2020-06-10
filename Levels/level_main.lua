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
local pan_x, pan_y = 1, 1
local texture_scale = 1
local tile_size

function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  drawbox_x, drawbox_y, texture_scale = grid.setOffset(0,0,5)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos[,options])
  for i=1,1296 do
    grid.fit(TYPE_DELAY)
  end
  for i=1,27 do
    for j=1,48 do
      if Grid[j][i] then
        if i%2 == 0 then
          Grid[j][i].delay = j
          Grid[j][i].color = COLOR_RED
        else
          Grid[j][i].delay = i
          Grid[j][i].color = COLOR_GREEN
        end
      end
    end
  end

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
end

return level