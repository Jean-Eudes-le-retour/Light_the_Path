io.stdout:setvbuf("no")

-- SETTING UP LOVE --

--Prevents low-res textures from looking blurry (get that neat sharp look on the game)
love.graphics.setDefaultFilter("nearest", "nearest")
--Name the window
love.window.setTitle("Light the Path")
--defaults 3rd parameter:windowflags = {fullscreen = false,fullscreentype = "desktop",vsync = 1,msaa = 0,stencil = true,depth = 0,resizable = false,borderless = false,centered = true,display = 1,minwidth = 1,minheight = 1}
--if window_width (respectively window_height) is 0, desktop width (respectively height) will be used.
love.window.setMode(0,0)

-- SETTING UP CONSTANTS --
require("constants")

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local game = require("game")
local debugUtils = require("debugUtils")

--temporary test var
local grid_dim_x, grid_dim_y = 0, 0
local grid_pos_x, grid_pos_y = 0, 0

--Important variables in main
local drawbox_x, drawbox_y, texture_scale = 0, 0, 0


function love.load()
  drawbox_x, drawbox_y, texture_scale = game.init(10,5)
  
  
--grid.fitNewObject(t,xpos,ypos,state,rotation,color,canMove,canChangeState,canChangeColor,glassState)
  grid_dim_x, grid_dim_y = grid.getDimensions()
  for i=1,grid_dim_x do
    grid.setNewObject(nil,i,1,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_x do
    grid.setNewObject(TYPE_WALL,i,grid_dim_y)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,1,i,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,grid_dim_x,i,nil,nil,nil,nil,nil,nil,0)
  end
  math.randomseed(os.time())
  for i=1,5 do
    --grid.fitNewObject((i%2)+1)
    grid.fitNewObject((math.floor(math.random()*20)%2)+1)
  end
  grid.fitNewObject(3,nil,nil,1,3,2 ,true)
  grid.fitNewObject(3,nil,nil,2,3,3,true)
  grid.fitNewObject(4,nil,nil,1,1,6)
  grid.fitNewObject(4,nil,nil,2,1,3)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,1,1,2)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,1,1,4)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,7)
  grid.fitNewObject(TYPE_PWHEEL,nil,nil,1,1,5)
  grid.fitNewObject(TYPE_PWHEEL,nil,nil,2,1,7)
  x=0
  totalTime=0.0
end

function love.update(dt)
  game.update(dt)
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  grid_pos_x, grid_pos_y = grid.getCursorPosition(true)

  x=x+10*dt
  totalTime = totalTime + dt --dt is in seconds
end

function love.draw()
  love.graphics.setCanvas()
  love.graphics.clear()
  love.graphics.draw(canvas_BG,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_GD,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_OL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_UI)
  love.graphics.print("X : "..string.sub(tostring(grid_pos_x),1,10))
  love.graphics.print("Y : "..string.sub(tostring(grid_pos_y),1,10),100,0)
  love.graphics.print("X_max : "..tostring(grid_dim_x),0,10)
  love.graphics.print("Y_max : "..tostring(grid_dim_y),100,10)
  love.graphics.print("Hello World!", x, 40)
end
