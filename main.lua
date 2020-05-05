io.stdout:setvbuf("no")

-- SETTING UP CONSTANTS --
require("constants")

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local game = require("game")
local debugUtils = require("debugUtils")

--temporary test var
local gridPosition_x, gridPosition_y = 0, 0
local grid_dim_x, grid_dim_y = 0, 0
local drawbox_x, drawbox_y, texture_scale = 0, 0, 0

function love.load()
  drawbox_x, drawbox_y, texture_scale = game.init()
  
  
--grid.fitNewObject(t,xpos,ypos,state,rotation,colour,canMove,canChangeState,canChangeColour,glassState)
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
  for i=1,30 do
    --grid.fitNewObject((i%2)+1)
    grid.fitNewObject((math.floor(math.random()*20)%2)+1)
  end
  grid.fitNewObject(3,nil,nil,nil,1,3,true)
  grid.fitNewObject(5)
  grid.fitNewObject(4)
  x=0
  totalTime=0.0
end

function love.update(dt)
  game.update(dt)
  x=x+10*dt
  totalTime = totalTime + dt --dt is in seconds
  gridPosition_x, gridPosition_y = grid.updateCursorPosition(true)
end

function love.draw()
  love.graphics.setCanvas()
  love.graphics.clear()
  love.graphics.draw(canvas_BG,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_GD,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_OL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_UI)
  love.graphics.print("X : "..tostring(gridPosition_x))
  love.graphics.print("Y : "..tostring(gridPosition_y),100,0)
  love.graphics.print("X_max : "..tostring(grid_dim_x),0,10)
  love.graphics.print("Y_max : "..tostring(grid_dim_y),100,10)
  love.graphics.print("Hello World!", x, 40)
end
