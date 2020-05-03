io.stdout:setvbuf("no")

-- SETTING UP CONSTANTS --
require("constants")

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local debugUtils = require("debugUtils")
local tiles = require("tiles")

--temporary test var
local cursor_posx, cursor_posy = 0, 0
local gridPosition_x, gridPosition_y = 0, 0
local grid_dim_x, grid_dim_y = 0, 0

function love.load()
  local box_x, box_y = grid.init()
  grid_dim_x, grid_dim_y = grid.getDimensions()
  for i=1,grid_dim_x do
    grid.setNewObject(nil,i,1,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_x do
    grid.setNewObject(TYPE_WALL,i,grid_dim_y,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,1,i,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,grid_dim_x,i,nil,nil,nil,nil,nil,nil,0)
  end
  grid.updateTypeState()
  grid.updateTypeState(2)
  print(Grid[1][1].t,Grid[1][1].state,Grid[1][1].rotation)
  print(Grid[2][1].t,Grid[2][1].state,Grid[2][1].rotation)
  print(Grid[3][1].t,Grid[3][1].state,Grid[3][1].rotation)
  print(Grid[1][1].glassState,Grid[1][1].glassRotation)
  print(Grid[2][1].glassState,Grid[2][1].glassRotation)
  print(Grid[3][1].glassState,Grid[3][1].glassRotation)
  x=0
  totalTime=0.0
  tiles.loadTextures()
end

function love.update(dt)
  x=x+10*dt
  totalTime = totalTime + dt --dt is in seconds
  cursor_posx, cursor_posy = love.mouse.getPosition()
  gridPosition_x, gridPosition_y = grid.updatePosition(cursor_posx, cursor_posy)
end

function love.draw()
  love.graphics.print("X : "..tostring(gridPosition_x).."    Y : "..tostring(gridPosition_y))
  love.graphics.print("X_max : "..tostring(grid_dim_x).."    Y_max : "..tostring(grid_dim_y),0,10)
  if grid_size_x then love.graphics.print("grid_size_x is defined and is : "..grid_size_x,0,20) end
  love.graphics.print("Hello World!", x, 100)
end

print("123")