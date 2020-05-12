local grid = require("grid")
local tiles = require("tiles")
local ui_elements = require("ui_elements")


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
  tiles.loadTextures()
  -- Menus = {MAIN_MENU}
  return grid.init(x_res,y_res,mode,x_val,y_val)
end

-- Function called to update the game state and canvases
function game.update(dt)
  grid.updateCursorPosition()
  game.updateUI(dt)
  tiles.update()
  -- all other tile updates and the such.
end

-- Update the UI canvas (all menu levels and cursor related graphics)
function game.updateUI(dt)
  local cursor_x, cursor_y = love.mouse.getPosition()
  local texture_scale = grid.getTextureScale()
  local UI_scale = ui_elements.getUIscale()
  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] then Menus[i].update(Menus[i]) end
  end
  love.graphics.setCanvas(canvas_UI)
  love.graphics.clear()
  for i=MenuId,1,-1 do
    if Menus[i] and Menus[i].canvas then --UI MISTAKE, UI_TILE's position mode is grid-based! MENU_GRID too!
      love.graphics.draw(Menus[i].canvas,Menus[i].xpos,Menus[i].ypos,nil,(Menus[i].t == UI_TILE) and texture_scale or UI_scale)
    end
  end

  if o_hand then
    local rotation = math.rad(90*o_hand.rotation)
    local state = o_hand.state
    tiles.drawTexture(o_hand.t,o_hand.state,o_hand.color)
    love.graphics.setCanvas(canvas_UI)
    love.graphics.draw(canvas_Texture,cursor_x+o_displacement_x,cursor_y+o_displacement_y,rotation,texture_scale)
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
        if Menus[i].buttons then
          for j=1,#Menus[i].buttons do
            if Menus[i]:isInButton(j) then
              Menus[i].buttons[j].texture_id = BUTTON_TEXTURE_PRESSED
              return true
            end
          end
        end
        return false
      elseif Menus[i].isBlocking then
        return false
      end
    end
  end
  
  if not (Grid[xpos] and Grid[xpos][ypos]) then
    if (button == 1) and (cursor_mode == CURSOR_SELECT) then sel_x, sel_y = false, false end
    if (button == 3) then sel_x, sel_y = false, false end
  elseif button == 1 then 
    if cursor_mode == CURSOR_MOVE then
      if (not DEVELOPER_MODE) and (Grid[xpos][ypos].glassState or not Grid[xpos][ypos].canMove) then return false end
      local tile_size = grid.getTileSize()
      o_hand = Grid[xpos][ypos]
      local rotation = o_hand.rotation
      xpos = xpos + ((rotation == 1 or rotation == 2) and 1 or 0)
      if rotation > 1 then ypos = ypos+1 end
      grid.deleteObject(nil,nil,o_hand,true)
      o_displacement_x, o_displacement_y = math.ceil((xpos-f_xpos-1)*tile_size), math.ceil((ypos-f_ypos-1)*tile_size)
    elseif cursor_mode == CURSOR_SELECT then
      sel_x, sel_y = xpos, ypos
    end
  elseif button == 2 then -- Will later make this button INTERACT with the block (o.state = o.state%NUM_STATES[o.t]+1) and move rotation to scroll wheel; remember: canChangeState only defined in default objects (not actual)
    if (not DEVELOPER_MODE) and (Grid[xpos][ypos].glassState or not Grid[xpos][ypos].canRotate) then return false end
    Grid[xpos][ypos]:rotate()
  elseif button == 3 then
    sel_x, sel_y = xpos, ypos
  end
  -- IF OTHERS UNDEFINED FOR NOW

end

function game.onScroll(x, y)
  local xpos, ypos = grid.getCursorPosition()

  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] then
      if Menus[i].isBlocking or Menus[i]:isInMenu() then
        return false
      end
    end
  end
  
  if Grid[xpos] and Grid[xpos][ypos] and (not Grid[xpos][ypos].glassState and Grid[xpos][ypos].canRotate or DEVELOPER_MODE) then
    Grid[xpos][ypos]:rotate(y > 0)
  end
end

-- The love callback function for mouse release (assignment is done in init). Defines behaviour.
function game.onRelease( x, y, button, istouch, presses )
  local xpos, ypos = grid.getCursorPosition()
  if button == 1 and o_hand then
    local bool = grid.moveObject(o_hand,xpos,ypos,o_hand.xpos,o_hand.ypos)
    o_hand = false
    return bool
  end
  local MenuId = ui_elements.getMenuId()
  for i=MenuId,1,-1 do
    if Menus[i] and Menus[i]:isInMenu() then
      if Menus[i].buttons then
        for j=1,#Menus[i].buttons do
          if Menus[i]:isInButton(j) and Menus[i].buttons[j].texture_id == BUTTON_TEXTURE_PRESSED then
            if Menus[i].buttons[j].onClick then Menus[i].buttons[j].onClick(Menus[i],Menus[i].buttons[j]) end
            if Menus[i] then Menus[i].buttons[j].texture_id = BUTTON_TEXTURE_HOVERED
            else return nil end
          end
        end
      end
    end
  end
end

return game