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
  drawbox_x, drawbox_y, texture_scale = game.init(20,10)
  
  
--grid.fitNewObject(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState,canChangeState)
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
  grid.fitNewObject(TYPE_SOURCE,nil,nil,1,3,COLOR_BLACK,true,true)
  grid.fitNewObject(TYPE_SOURCE,nil,nil,2,3,(math.floor(math.random()*20)%7)+1,true,true)
  grid.fitNewObject(TYPE_SOURCE,nil,nil,2,3,(math.floor(math.random()*20)%7)+1,true,true)
  grid.fitNewObject(TYPE_RECEIVER,nil,nil,1,1,COLOR_BLACK,true,true)
  grid.fitNewObject(TYPE_RECEIVER,nil,nil,2,1,3)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,1,1,2)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,1,1,4)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,7)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,COLOR_WHITE)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,COLOR_WHITE)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,COLOR_WHITE)
  grid.fitNewObject(TYPE_MIRROR,nil,nil,2,1,COLOR_BLACK)
  grid.fitNewObject(TYPE_PWHEEL,nil,nil,1,1,5)
  grid.fitNewObject(TYPE_PWHEEL,nil,nil,2,1,7)
  grid.fitNewObject(TYPE_LOGIC,nil,nil,LOGIC_OR,nil,nil,true,true):setSides(nil,"in","in","out")
  grid.fitNewObject(TYPE_LOGIC,nil,nil,LOGIC_AND,nil,nil,true,true):setSides("in","in","in","out")
  grid.fitNewObject(TYPE_LOGIC,nil,nil,LOGIC_AND,nil,nil,true,true):setSides("in",nil,"in","out")
  grid.fitNewObject(TYPE_LOGIC,nil,nil,LOGIC_NOT,nil,nil,true,true):setSides(nil,"in","in","out")
  grid.fitNewObject(TYPE_RECEIVER,nil,nil,nil,nil,COLOR_BLACK,true,true):setSides(nil,nil,"activate",nil)
  grid.setNewObject(TYPE_RECEIVER,17,8,nil,3,COLOR_WHITE,false,false,false,true):setSides(nil,nil,"activate",nil)
  grid.setNewObject(TYPE_SOURCE,18,8,nil,2,COLOR_WHITE,false,false,false,true,false)
  grid.setNewObject(TYPE_MIRROR,16,9,2,1,COLOR_CYAN,false,false,false,true,false)
  grid.setNewObject(TYPE_DELAY,17,9,2)
  grid.setNewObject(TYPE_LOGIC,16,8,LOGIC_NOT,nil,COLOR_WHITE,false,false,false,true,false):setSides(nil,"out","in")
  grid.setNewObject(TYPE_LOGIC,18,9,LOGIC_AND,nil,COLOR_BLACK,false,false,false,true,false):setSides("in","out",nil,"in")
  grid.setNewObject(TYPE_RECEIVER,19,9,nil,3,COLOR_RED,false,false,false,true,false)
  grid.fitNewObject(TYPE_DELAY,nil,nil,60)
  
  ui_elements.dialogTest()
end

function love.update(dt)
  game_time = game_time + dt --dt is in seconds, should be 0.0166-repeating on average (60 FPS capped)
  game.update(dt)
  if level and level.update then level.update(dt) end
  if level and level.complete then --[[open victory menu]] end
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  grid_pos_x, grid_pos_y = grid.getCursorPosition(true)
end

function love.draw()
  love.graphics.setCanvas()
  love.graphics.clear()
  love.graphics.setBlendMode("alpha","premultiplied")
  love.graphics.draw(canvas_BG,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_LL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_GD,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_OL,drawbox_x,drawbox_y,nil,texture_scale)
  love.graphics.draw(canvas_UI)
  love.graphics.setBlendMode("alpha")
  love.graphics.print("X : "..string.sub(tostring(grid_pos_x),1,10))
  love.graphics.print("Y : "..string.sub(tostring(grid_pos_y),1,10),100,0)
  love.graphics.print("X_max : "..tostring(grid_dim_x),0,10)
  love.graphics.print("Y_max : "..tostring(grid_dim_y),100,10)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 0, 25)
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
  
  for i=1,ui_elements.getMenuId() do
    if Menus[i] and Menus[i].t == UI_DIALOG then Menus[i]:close() end
  end
  
  level = love.filesystem.load(path)()
  level.load()
  grid_dim_x, grid_dim_y = grid.getDimensions()
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  if not level.track_id then level.track_id = math.ceil(math.random()*#TRACK) end
  game.audio.fadein(level.track_id,level.volume,1)
end
