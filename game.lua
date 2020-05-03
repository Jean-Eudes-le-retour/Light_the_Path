local grid = require("grid")
local tiles = require("tiles")


-- HIGH LEVEL GAME FUNCTIONS, ideally functions that provide user with UI and defines behaviour when player takes certain actions
local game = {}

local cursor_mode = 1
local o_hand = false
local o_hand = false
local o_displacement_x, o_displacement_y = 0,0
canvas_UI = love.graphics.newCanvas() -- WILL NEED TO MOVE INTO WHICHEVER FUNCTION CHANGES SCREEN RESOLUTION

function game.init()
  love.mousepressed = game.onClick
  love.mousereleased = game.onRelease
end

function game.update()
  grid.updateCursorPosition()
  game.updateUI()
  tiles.update()
  -- all other tile updates and the such.
end

function game.updateUI()
  love.graphics.setCanvas(canvas_UI)
  love.graphics.clear()
  local cursor_x, cursor_y = love.mouse.getPosition()

  if o_hand then
    local tile_size = grid.getTileSize()
    local state = o.state
    if state >= NUM_STATES[o.t] then state = 1 end
    love.graphics.drawLayer(TEXTURES[o.t],state,cursor_x+o_displacement_x*tile_size,cursor_y+o_displacement_y*tile_size)
  end
  -- DRAW CUSTOM CURSORS
  
  love.graphics.setCanvas()
end

function game.onClick( x, y, button, istouch, presses )
  local grid_size_x, grid_size_y = grid.getDimensions()
  local f_xpos, f_ypos = grid.getCursorPosition(true)
  local xpos, ypos = grid.getCursorPosition()
  -- IF GAME IS ACTIVE -- DEFINE GLOBAL FLAGS SO THAT WE CAN USE MENUS AND HAVE TEXT CONVERSATION MODES TOO!
  if not (Grid[xpos] and Grid[xpos][ypos]) then return false end
  if cursor_mode == CURSOR_MOVE then
    if Grid[xpos][ypos].glassState or not Grid[xpos][ypos].canMove then return false end
    o_hand = Grid[xpos][ypos]
    grid.deleteObject(nil,nil,o_hand,true)
    o_displacement_x, o_displacement_y = xpos-f_xpos, ypos-f_ypos
  end
  -- IF OTHERS UNDEFINED FOR NOW

end

function game.onRelease( x, y, button, istouch, presses )
  local xpos, ypos = grid.getCursorPosition()
  if button == 1 and o_hand then
    local bool = grid.moveObject(o_hand,xpos,ypos,o_hand.xpos,o_hand.ypos)
    local tmpx, tmpy, tmpid, tmpt = o.xpos, o.ypos, o.id, o.t
    o_hand = false
    print(type(Grid[tmpx][tmpy]))
    print(ObjectReferences[tmpt][tmpid])
    return bool
  end
end

return game