io.stdout:setvbuf("no")

-- SETTING UP CONSTANTS --
require("constants")

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local debugUtils = require("debugUtils")
local tiles = require("tiles")

--temporary test var
local gridPosition_x, gridPosition_y = 0, 0
local grid_dim_x, grid_dim_y = 0, 0
local drawbox_x, drawbox_y, texture_scale = 0, 0, 0

function love.load()
  drawbox_x, drawbox_y, texture_scale = grid.init(nil,nil,nil,-0.5)
  grid_dim_x, grid_dim_y = grid.getDimensions()
  for i=1,grid_dim_x do
    grid.setNewObject(nil,i,1,nil,nil,nil,nil,nil,nil,0)
  end
  for i=2,grid_dim_x-1 do
    grid.setNewObject(TYPE_GLASS,i,2)
  end
  for i=1,grid_dim_x do
    grid.setNewObject(TYPE_WALL,i,grid_dim_y,nil,nil,nil,true)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,1,i,nil,nil,nil,nil,nil,nil,0)
  end
  for i=1,grid_dim_y do
    grid.setNewObject(TYPE_WALL,grid_dim_x,i,nil,nil,nil,nil,nil,nil,0)
  end
  x=0
  totalTime=0.0
  
  for i=1,#UpdateObjectType do
    print(TYPES[i]..(UpdateObjectType[i] and " NEED UPDATE" or " are set"))
  end
  tiles.loadTextures()
  tiles.update()
  for i=1,#UpdateObjectType do
    print(TYPES[i]..(UpdateObjectType[i] and " NEED UPDATE" or " are set"))
  end
  
  
  print(TYPES[Grid[1][1].t],Grid[1][1].state,Grid[1][1].rotation)
  print(TYPES[Grid[2][1].t],Grid[2][1].state,Grid[2][1].rotation)
  print(TYPES[Grid[3][1].t],Grid[3][1].state,Grid[3][1].rotation)
  print(Grid[1][1].glassState,Grid[1][1].glassRotation)
  print(Grid[2][1].glassState,Grid[2][1].glassRotation)
  print(Grid[3][1].glassState,Grid[3][1].glassRotation)
end

function love.update(dt)
  x=x+10*dt
  totalTime = totalTime + dt --dt is in seconds
  gridPosition_x, gridPosition_y = grid.updateCursorPosition(true)
end

function love.draw()
  love.graphics.draw(canvas_BG,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_WL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_GL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.print("X : "..tostring(gridPosition_x))
  love.graphics.print("Y : "..tostring(gridPosition_y),100,0)
  love.graphics.print("X_max : "..tostring(grid_dim_x),0,10)
  love.graphics.print("Y_max : "..tostring(grid_dim_y),100,10)
  if grid_size_x then love.graphics.print("grid_size_x is defined and is : "..grid_size_x,0,20) end
  love.graphics.print("Hello World!", x, 40)
  --love.graphics.drawLayer(TEXTURES[1],1,100,100,math.rad(90*2),5) -- to check how rotation is handled
end

print("123")