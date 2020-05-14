io.stdout:setvbuf("no")

-- SETTING UP CONSTANTS --
require("constants")

-- SETTING UP LOVE --

--Prevents low-res textures from looking blurry (get that neat sharp look on the game)
love.graphics.setDefaultFilter("nearest", "nearest")
--Name the window
love.window.setTitle("Light the Path")
--defaults 3rd parameter:windowflags = {fullscreen = false,fullscreentype = "desktop",vsync = 1,msaa = 0,stencil = true,depth = 0,resizable = false,borderless = false,centered = true,display = 1,minwidth = 1,minheight = 1}
--if window_width (respectively window_height) is 0, desktop width (respectively height) will be used.
love.window.setMode(DEFAULT_SCREEN_WIDTH,DEFAULT_SCREEN_HEIGHT,{["resizable"] = true})

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local game = require("game")
local ui_elements = require("ui_elements")
local debugUtils = require("debugUtils")

--temporary test var
local grid_dim_x, grid_dim_y = 0, 0
local grid_pos_x, grid_pos_y = 0, 0

--Important variables in main
local drawbox_x, drawbox_y, texture_scale = 0, 0, 0
game_time = 0
level = false


function love.load()
  drawbox_x, drawbox_y, texture_scale = game.init(10,5)
  
  
--grid.fitNewObject(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
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
  
  
  local m = ui_elements.create(UI_MENU)
  --m.texture[0] = ui_elements.getNewMenuBackground(200,300)
  m.buttons = {{xpos = 20, ypos = 5, onClick = function(m,b) m:close() end, text = "Return to Game"},{xpos = 20, ypos = 5, onClick = function(m,b) m:close() end, text = "Return to Game"},{xpos = 20, ypos = 5, onClick = function(m,b) m:close() end, text = "Return to Game"}}
  m.texture[1] = love.graphics.newImage("Textures/default_button_1.png")
  ui_elements.fitButtons(m)

  m.window_position_mode = MENU_CENTER
  m.isBlocking = true
  m.texture[2] = love.graphics.newImage("Textures/default_button_2.png")

  ui_elements.updateButtonDimensions(m) --unnecessary when using ui_elements.fitButtons(m)
  m:resize()
  
  
end

function love.update(dt)
  game_time = game_time + dt --dt is in seconds, should be 0.0166-repeating on average (60 FPS capped)
  game.update(dt)
  if level and level.update then level.update(dt) end
  if level and level.complete then --[[open victory menu]] end
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  grid_pos_x, grid_pos_y = grid.getCursorPosition(true)

  x=x+10*dt
end

function love.draw()
  love.graphics.setCanvas()
  love.graphics.clear()
  love.graphics.setBlendMode("alpha","premultiplied")
  love.graphics.draw(canvas_BG,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_GD,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_OL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_UI)
  love.graphics.setBlendMode("alpha")
  love.graphics.print("X : "..string.sub(tostring(grid_pos_x),1,10))
  love.graphics.print("Y : "..string.sub(tostring(grid_pos_y),1,10),100,0)
  love.graphics.print("X_max : "..tostring(grid_dim_x),0,10)
  love.graphics.print("Y_max : "..tostring(grid_dim_y),100,10)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 0, 25)
  love.graphics.print("Hello World!", x, 40)
end

--Global callback function for when the screen was resized EXTERNALLY, or resized INTERNALLY with bad parameters; width and height in DPI scaled-units (???)
function love.resize(width,height,dontResetUI)
  if type(level) == "table" then
    drawbox_x, drawbox_y, texture_scale = grid.defineDrawbox(level.drawbox_mode, level.x_val, level.y_val)
  else
    drawbox_x, drawbox_y, texture_scale = grid.defineDrawbox()
  end
  if dontResetUI then return end
  canvas_UI = love.graphics.newCanvas()
  local UI_autoscaling, UI_autoscale_factor_x, UI_autoscale_factor_y = ui_elements.getUIScaleMode()
  if UI_autoscaling then
    local window_w, window_h = love.graphics.getDimensions()
    ui_elements.changeUIScale(math.min(window_w*UI_autoscale_factor_x, window_h*UI_autoscale_factor_y))
  end
  ui_elements.redraw()
end

function load_level(level_no)
  if type(level_no) ~= "string" then level_no = tostring(level_no) end
  local path = nil
  local name = "level_"..level_no
  local Files = love.filesystem.getDirectoryItems("Levels/")
  for i=1,#Files do
    if string.find(Files[i],name) then
      local namelength = string.len(name)
      local nextchar = string.sub(Files[i],namelength+1,namelength+1)
      if nextchar == "_" or nextchar == "." then
        path = Files[i]
        break
      end
    end
  end
  path = "Levels/"..path
  
  if not file_exists(path) then
    print("Could not find "..path)
    return false
  end
  level = dofile(path)
  level.load()
  grid_dim_x, grid_dim_y = grid.getDimensions()
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
end
