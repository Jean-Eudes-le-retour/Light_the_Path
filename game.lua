local objects = require("objects")
local grid = require("grid")
local tiles = require("tiles")
local ui_elements = require("ui_elements")
local laser = require("laser")
local audio = require("audio")


-- HIGH LEVEL GAME FUNCTIONS, ideally functions that provide user with UI and defines behaviour when player takes certain actions
local game = {}

local cursor_mode = 1
local o_hand = false
local o_displacement_x, o_displacement_y = 0,0
local sel_x, sel_y =  false, false
canvas_UI = love.graphics.newCanvas() -- WILL NEED TO MOVE INTO WHICHEVER FUNCTION CHANGES SCREEN RESOLUTION

-- Initializes game (Maybe we can move the definition of callback functions into main, but this gives us more control for now)
function game.init(x_res,y_res,mode,x_val,y_val)
  love.mousepressed = game.onClick
  love.mousereleased = game.onRelease
  love.wheelmoved = game.onScroll
  love.keypressed = game.onPress
  tiles.loadTextures()
  if (not x_res) or (not y_res) then
    ui_elements.mainMenu()
    return grid.getDrawboxInfo()
  else
    return grid.init(x_res,y_res,mode,x_val,y_val)
  end
end

-- Function called to update the game state and canvases
function game.update(dt)
  grid.updateCursorPosition()
  game.updateUI(dt)
  audio.update(dt)
  laser.update()
  tiles.update()
  -- all other tile updates and the such.
end

-- Update the UI canvas (all menu levels and cursor related graphics)
function game.updateUI(dt)
  local cursor_x, cursor_y = love.mouse.getPosition()
  local texture_scale = grid.getTextureScale()
  local UI_scale = ui_elements.getUIScale()
  local MenuId = ui_elements.getMenuId()
  
  for i=MenuId,1,-1 do if Menus[i] then Menus[i].update(Menus[i]) end end

  if audio.getMuffle() then
    local muffling = false
    for i=1,MenuId do muffling = muffling or (Menus[i] and Menus[i].t ~= UI_DIALOG and Menus[i].isBlocking) end
    if not muffling then audio.muffle(false) end
  end

  love.graphics.setCanvas(canvas_UI)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha","premultiplied")
  for i=1,MenuId do
    if Menus[i] and Menus[i].canvas then
      love.graphics.draw(Menus[i].canvas,Menus[i].xpos,Menus[i].ypos,nil,(Menus[i].t == UI_TILE) and texture_scale or UI_scale)
    end
  end
  love.graphics.setBlendMode("alpha")

  if o_hand then
    local rotation = math.rad(90*o_hand.rotation)
    local state = o_hand.state
    tiles.drawTexture(o_hand.t,o_hand.state,o_hand.color,o_hand.side)
    love.graphics.setBlendMode("alpha","premultiplied")
    love.graphics.setCanvas(canvas_UI)
    love.graphics.draw(canvas_Texture,cursor_x+o_displacement_x,cursor_y+o_displacement_y,rotation,texture_scale)
    love.graphics.setBlendMode("alpha")
  end
  love.graphics.setCanvas()
  
  -- DRAW CUSTOM CURSORS
  
  
end

-- The love callback function for mouse presses (assignment is done in init). Defines behaviour.
function game.onClick( x, y, button, istouch, presses )
  local grid_size_x, grid_size_y = grid.getDimensions()
  local f_xpos, f_ypos = grid.getCursorPosition(true)
  local xpos, ypos = grid.getCursorPosition()
  -- IF GAME IS ACTIVE -- DEFINE GLOBAL FLAGS SO THAT WE CAN USE MENUS AND HAVE TEXT CONVERSATION MODES TOO!

  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] then
      if Menus[i]:isInMenu() then
        if (button == 1) then
          if Menus[i].t == UI_DIALOG then ui_elements.clickDialog(Menus[i])
          elseif Menus[i].buttons then
            for j=1,#Menus[i].buttons do
              if Menus[i]:isInButton(j) then
                Menus[i].buttons[j].pressed = true
                -- if Menus[i].buttons[j].onClick then audio.playSound(SFX_BUTTON_PRESS) end
                return true
              end
            end
          end
        end
        return false
      elseif Menus[i].isBlocking then
        return false
      end
    end
  end
  
  if (DEVELOPER_MODE or level.canModify) and (button == 3) or (button == 1) and (cursor_mode == CURSOR_SELECT) then ui_elements.select(xpos,ypos) end
  
  if (Grid[xpos] and Grid[xpos][ypos]) then
    if button == 1 then 
      if cursor_mode == CURSOR_MOVE then
        if (not DEVELOPER_MODE) and (Grid[xpos][ypos].glass or not Grid[xpos][ypos].canMove) then return false end
        local tile_size = grid.getTileSize()
        o_hand = Grid[xpos][ypos]
        audio.playSound(1 + objects.getSFXOffset(o_hand.t))
        local rotation = o_hand.rotation
        xpos = xpos + ((rotation == 1 or rotation == 2) and 1 or 0)
        if rotation > 1 then ypos = ypos+1 end
        grid.delete(nil,nil,o_hand,true)
        o_displacement_x, o_displacement_y = math.ceil((xpos-f_xpos-1)*tile_size), math.ceil((ypos-f_ypos-1)*tile_size)
      end
    elseif button == 2 then
      if (not DEVELOPER_MODE) and (Grid[xpos][ypos].glass or not Grid[xpos][ypos].canChangeState) then return false end
      Grid[xpos][ypos]:changeState(f_xpos, f_ypos)
    end
  end
  -- IF OTHERS UNDEFINED FOR NOW

end

function game.onScroll(x, y)
  local xpos, ypos = grid.getCursorPosition()

  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] then
      if Menus[i].isBlocking or Menus[i]:isInMenu() then
        if Menus[i].onScroll then
          Menus[i].onScroll(Menus[i],x,y)
          audio.playSound(SFX_TICK)
          return true
        end
        return false
      end
    end
  end
  
  if Grid[xpos] and Grid[xpos][ypos] and ((not Grid[xpos][ypos].glass and Grid[xpos][ypos].canRotate) or DEVELOPER_MODE) then
    Grid[xpos][ypos]:rotate(y > 0)
  end
end

-- The love callback function for mouse release (assignment is done in init). Defines behaviour.
function game.onRelease( x, y, button, istouch, presses )
  local xpos, ypos = grid.getCursorPosition()
  if button == 1 and o_hand then
    local bool = grid.move(o_hand,xpos,ypos)
    o_hand = false
    return bool
  end
  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] and Menus[i]:isInMenu() then
      local uniqueId = Menus[i].uniqueId
      if Menus[i].buttons then
        for j=1,#Menus[i].buttons do
          if Menus[i]:isInButton(j) and Menus[i].buttons[j].pressed then
            Menus[i].buttons[j].pressed = false
            if Menus[i].buttons[j].onClick then
              Menus[i].buttons[j].onClick(Menus[i],Menus[i].buttons[j])
              audio.playSound(SFX_BUTTON_RELEASE)
            end
            return true
          end
        end
      end
    end
  end
end

function game.onPress( key, scancode, isrepeat)
  local MenuId = ui_elements.getMenuId()
  local blocked = false
  for i=1,MenuId do
    blocked = blocked or Menus[i] and Menus[i].isBlocking
  end

  if key == "escape" then
    if laser.isHalted() then
      laser.halt(false)
    else
      for i=MenuId,1,-1 do
        if Menus[i] and Menus[i].isBlocking and Menus[i].t ~= UI_DIALOG then
          if Menus[i].noEscape then return end
          Menus[i]:close()
          return
        end
      end
      ui_elements.escapeMenu()
      return
    end
  elseif key == "space" then
    if not blocked then laser.step() end
  end

end

return game