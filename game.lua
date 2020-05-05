local grid = require("grid")
local tiles = require("tiles")


-- HIGH LEVEL GAME FUNCTIONS, ideally functions that provide user with UI and defines behaviour when player takes certain actions
local game = {}

local cursor_mode = 1
local o_hand = false
local o_displacement_x, o_displacement_y = 0,0
local sel_x, sel_y =  false, false
canvas_UI = love.graphics.newCanvas() -- WILL NEED TO MOVE INTO WHICHEVER FUNCTION CHANGES SCREEN RESOLUTION

function game.init()
  love.mousepressed = game.onClick
  love.mousereleased = game.onRelease
  tiles.loadTextures()
  -- Menus = {MAIN_MENU}
  return grid.init()
end

function game.update(dt)
  grid.updateCursorPosition()
  game.updateUI(dt)
  tiles.update()
  -- all other tile updates and the such.
end

function game.updateUI(dt)
  love.graphics.setCanvas(canvas_UI)
  love.graphics.clear()
  local cursor_x, cursor_y = love.mouse.getPosition()

  if o_hand then
    local texture_scale = grid.getTextureScale()
    local rotation = math.rad(90*o_hand.rotation)
    local state = o_hand.state
    if state >= NUM_STATES[o_hand.t] then state = 1 end
    tiles.drawTexture(o_hand.t,1,o_hand.colour)
    love.graphics.setCanvas(canvas_UI)
    love.graphics.draw(canvas_Texture,cursor_x+o_displacement_x,cursor_y+o_displacement_y,rotation,texture_scale)
  end
  -- DRAW CUSTOM CURSORS
  love.graphics.setCanvas()
end

function game.onClick( x, y, button, istouch, presses )
  local grid_size_x, grid_size_y = grid.getDimensions()
  local f_xpos, f_ypos = grid.getCursorPosition(true)
  local xpos, ypos = grid.getCursorPosition()
  -- IF GAME IS ACTIVE -- DEFINE GLOBAL FLAGS SO THAT WE CAN USE MENUS AND HAVE TEXT CONVERSATION MODES TOO!
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
  elseif button == 3 then
    sel_x, sel_y = xpos, ypos
  end
  -- IF OTHERS UNDEFINED FOR NOW

end

function game.onRelease( x, y, button, istouch, presses )
  local xpos, ypos = grid.getCursorPosition()
  if button == 1 and o_hand then
    local bool = grid.moveObject(o_hand,xpos,ypos,o_hand.xpos,o_hand.ypos)
    o_hand = false
    return bool
  end
end

return game