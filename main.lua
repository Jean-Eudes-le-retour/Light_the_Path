io.stdout:setvbuf("no")

-- SETTING UP LOVE --
--Prevents low-res textures from looking blurry (get that neat sharp look on the game)
love.graphics.setDefaultFilter("nearest", "nearest")

-- SETTING UP CONSTANTS --
require("constants")

-- LOADING MODULES --
local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local laser = require("laser")
local game = require("game")
local ui_elements = require("ui_elements")
local audio = require("audio")
local debugUtils = require("debugUtils")

--Important variables in main
local drawbox_x, drawbox_y, texture_scale = 0, 0, 0
game_time = 0
level = false
cursor_mode = CURSOR_MOVE

--Developer info variables
local grid_dim_x, grid_dim_y = 0, 0
local grid_pos_x, grid_pos_y = 0, 0

function love.load()
  --[[ GO DIRECTLY TO MAIN MENU IF NOT IN DEVELOPER MODE
  if not DEVELOPER_MODE then
    drawbox_x, drawbox_y, texture_scale = game.init()
    return
  end]]

  drawbox_x, drawbox_y, texture_scale = game.init(20,10) --remove variables for main menu
  level = {}
  level.canModify = true
  
--grid.fit(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glass,canChangeState)
  grid_dim_x, grid_dim_y = grid.getDimensions()
  for i=1,grid_dim_x do
    grid.set(nil,i,1,{glass = true})
  end
  for i=1,grid_dim_x do
    grid.set(TYPE_WALL,i,grid_dim_y)
  end
  for i=1,grid_dim_y do
    grid.set(TYPE_WALL,1,i,{glass = true})
  end
  for i=1,grid_dim_y do
    grid.set(TYPE_WALL,grid_dim_x,i,{glass = true})
  end
  math.randomseed(os.time())
  for i=1,5 do
    --grid.fit((i%2)+1)
    grid.fit((math.floor(math.random()*20)%2)+1)
  end
  grid.fit(TYPE_SOURCE,nil,nil,{state = 1, rotation = 3, color = COLOR_BLACK, canMove = true, canRotate = true})
  grid.fit(TYPE_SOURCE,nil,nil,{state = 2, rotation = 3, color = (math.floor(math.random()*20)%7)+1, canMove = true, canRotate = true})
  grid.fit(TYPE_SOURCE,nil,nil,{state = 2, rotation = 3, color = (math.floor(math.random()*20)%7)+1, canMove = true, canRotate = true})
  grid.fit(TYPE_RECEIVER,nil,nil,{state = 1, rotation = 1, color = COLOR_BLACK, canMove = true, canRotate = true, canChangeState = true})
  grid.fit(TYPE_RECEIVER,nil,nil,{state = 2, rotation = 1, color = 3, canChangeState = true})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 1, rotation = 1, color = 2})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 1, rotation = 1, color = 4})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 2, rotation = 1, color = 7})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 2, rotation = 1, color = COLOR_WHITE})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 2, rotation = 1, color = COLOR_WHITE})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 2, rotation = 1, color = COLOR_WHITE})
  grid.fit(TYPE_MIRROR,nil,nil,{state = 2, rotation = 1, color = COLOR_BLACK})
  grid.fit(TYPE_PWHEEL,nil,nil,{state = 1, rotation = 1, color = 5})
  grid.fit(TYPE_PWHEEL,nil,nil,{state = 2, rotation = 1, color = 7})
  grid.fit(TYPE_LOGIC,nil,nil,{state = LOGIC_OR, canMove = true, canRotate = true, canChangeState = true}):setSides(nil,"in","in","out")
  grid.fit(TYPE_LOGIC,nil,nil,{state = LOGIC_AND, canMove = true, canRotate = true, canChangeState = true}):setSides("in","in","in","out")
  grid.fit(TYPE_LOGIC,nil,nil,{state = LOGIC_AND, canMove = true, canRotate = true, canChangeState = true}):setSides("in",nil,"in","out")
  grid.fit(TYPE_LOGIC,nil,nil,{state = LOGIC_NOT, canMove = true, canRotate = true, canChangeState = true}):setSides(nil,"in","in","out")
  grid.fit(TYPE_RECEIVER,nil,nil,{color = COLOR_BLACK, canMove = true, canRotate = true, canChangeState = true}):setSides(nil,nil,"activate",nil)
  grid.fit(TYPE_LOGIC,nil,nil,{canRotate = true, canChangeState = true})

  grid.set(TYPE_RECEIVER,17,8,{rotation = 3, color = COLOR_WHITE, glass = true}):setSides(nil,nil,"activate",nil)
  grid.set(TYPE_SOURCE,18,8,{rotation = 2, color = COLOR_WHITE, glass = true})
  grid.set(TYPE_MIRROR,16,9,{state = 2, rotation = 1, color = COLOR_CYAN, glass = true})
  grid.set(TYPE_DELAY,17,9,{delay = 2, glass = true})
  grid.set(TYPE_LOGIC,16,8,{state = LOGIC_NOT, color = COLOR_WHITE, glass = true}):setSides(nil,"out","in")
  grid.set(TYPE_LOGIC,18,9,{state = LOGIC_AND, color = COLOR_BLACK, glass = true}):setSides("in","out",nil,"in")
  grid.set(TYPE_RECEIVER,19,9,{rotation = 3, color = COLOR_RED, glass  =true})
  grid.set(TYPE_GLASS,19,8)
  grid.fit(TYPE_DELAY,nil,nil,{delay = 60})
  for i=1,50 do
    grid.fit(TYPE_DELAY,nil,nil,{delay = 5})
  end
  
  ui_elements.makeLevelMenu()
  ui_elements.dialogTest()
end

function love.update(dt)
  game_time = game_time + dt --dt is in seconds, should be 0.0166-repeating on average (60 FPS capped)
  game.update(dt)
  if level and level.update then level.update(dt) end
  if level and level.complete then
    local blocked = false
    for i=1,ui_elements.getMenuId() do
      blocked = blocked or (Menus[i] and Menus[i].isBlocking)
    end
    if not blocked then audio.muffle(true) ui_elements.victory() end
  end
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  grid_pos_x, grid_pos_y = grid.getCursorPosition(true)
  grid_dim_x, grid_dim_y = grid.getDimensions()
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
  if DEVELOPER_MODE then
    love.graphics.print("X : "..string.sub(tostring(grid_pos_x),1,10))
    love.graphics.print("Y : "..string.sub(tostring(grid_pos_y),1,10),100,0)
    love.graphics.print("X_max : "..tostring(grid_dim_x),0,15)
    love.graphics.print("Y_max : "..tostring(grid_dim_y),100,15)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 0, 30)
  end
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

function DEFAULT_LEVEL_UPDATE()
  level.complete = true
  for i=1,object.getId(TYPE_RECEIVER) do
    local receiver = ObjectReferences[TYPE_RECEIVER][i]
    if receiver then level.complete = level.complete and (receiver.state==2) end
  end
end

function load_level(level_id)
  if type(level_id) ~= "string" then level_id = tostring(level_id) end
  local path = nil
  local name = "level_"..level_id
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
  
  for i=0,ui_elements.getMenuId() do
    if Menus[i] and (Menus[i].t == UI_DIALOG or Menus[i].isSelection) then Menus[i]:close() end
  end
  
  laser.halt(false)
  level = love.filesystem.load(path)()
  level.load()
  level.level_id = level_id
  grid_dim_x, grid_dim_y = grid.getDimensions()
  drawbox_x, drawbox_y, texture_scale = grid.getDrawboxInfo()
  if not level.track_id then
    if type(level.track_id) == "nil" then
      audio.play(math.ceil(math.random()*#TRACK),{loop = true})
    else
      audio.fade()
    end
  else
    audio.play(level.track_id,{loop = true})
  end
  if not level.update then level.update = DEFAULT_LEVEL_UPDATE end
  cursor_mode = CURSOR_MOVE
  local m = ui_elements.makeLevelMenu()
  print(m.id)
end
