local objects = require("objects")  -- Used to iterate on objects (objects.getId()...) for example check every receiver for win condition; be careful with functions in this module, some only modify the information stored on the object, not the grid!
local grid = require("grid")        -- Used to modify or observe the grid and its content.
local tiles = require("tiles")      -- Possibly used to interact directly with the game state (interactive level functions), or for the versatile drawTexture function.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 30
level.y = 15
level.name = "Puzzle 4"

-- OPTIONAL VARIABLES --
level.drawbox_mode = nil
level.x_val = nil
level.y_val = nil

-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
  
-- PREPARE LEVEL -- use grid.set(...) or grid.fit(...)
--grid.fit(t,xpos,ypos,state,rotation,color,canMove,canRotate,canChangeColor,glassState)
  for i=1,13 do
    grid.set(TYPE_WALL, i, 1)
    grid.set(TYPE_WALL, i+18, 1)
    grid.set(TYPE_WALL, i, 2)
    grid.set(TYPE_WALL, i+18, 2)
    grid.set(TYPE_WALL, i, 3)
    grid.set(TYPE_WALL, i+18, 3)
    grid.set(TYPE_WALL, i, 4)
    grid.set(TYPE_WALL, i+18, 4)
  end
  for i=11,15 do
    grid.set(TYPE_WALL, i, 5)
    grid.set(TYPE_WALL, i+6, 5)
    grid.set(TYPE_WALL, i, 6)
    grid.set(TYPE_WALL, i+6, 6)
    grid.set(TYPE_WALL, i, 8)
    grid.set(TYPE_WALL, i+6, 8)
    grid.set(TYPE_WALL, i, 9)
    grid.set(TYPE_WALL, i+6,9)
    grid.set(TYPE_WALL, i, 11)
    grid.set(TYPE_WALL, i+6, 11)
    grid.set(TYPE_WALL, i, 12)
    grid.set(TYPE_WALL, i+6,12)
  end
  for i=11,21 do
    grid.set(TYPE_WALL, i, level.y-1)
    grid.set(TYPE_WALL, i, level.y)
  end
  for i=1,15 do
    grid.set(TYPE_WALL, i, 10)
    grid.set(TYPE_WALL, i+16,10)
  end
  grid.set(TYPE_SOURCE, level.x, 7, {rotation =  3, color =  COLOR_CYAN})
  grid.set(TYPE_SOURCE, 1, 12, {rotation =  1,  color =  COLOR_MAGENTA})
  grid.set(TYPE_SOURCE, 3, 9, {rotation =  0,  color =  COLOR_YELLOW})
  grid.set(TYPE_SOURCE, level.x, level.y-1 , {rotation =  3, color =  COLOR_BLUE})
  grid.set(TYPE_RECEIVER, 16, 1, {rotation =  2, color =  COLOR_WHITE})
  grid.set(TYPE_RECEIVER, 6, 9, {rotation =  0, color =  COLOR_RED})
  grid.set(TYPE_RECEIVER, 23, 9, {rotation =  0, color =  COLOR_GREEN})
  grid.set(TYPE_RECEIVER, 8, level.y, {rotation = 0, color =  COLOR_BLUE})
  grid.set(TYPE_RECEIVER, 23, 11, {rotation =  2, color =  COLOR_YELLOW})
  grid.set(TYPE_PWHEEL, 15, 1, {rotation = 1, color = COLOR_YELLOW})
  grid.set(TYPE_MIRROR, 1, level.y , {rotation = 1})
  grid.set(TYPE_MIRROR, 26, 11, {rotation = 1})
  grid.set(TYPE_LOGIC, 1, 6,{state = LOGIC_OR, canMove = true, canRotate = true}):setSides("in","in","in","out")
  grid.set(TYPE_LOGIC, 2, 6,{state = LOGIC_OR, canMove = true, canRotate = true}):setSides("in","in","in","out")
  grid.set(TYPE_MIRROR, 26, 6, {state =  1, color =  COLOR_RED})
  grid.set(TYPE_MIRROR, 17,2 , {state =  1, color =  COLOR_RED})
  grid.set(TYPE_MIRROR, 2, level.y, {state =  1, color =  COLOR_GREEN})
  grid.set(TYPE_MIRROR, 17,3 , {state =  1, color =  COLOR_YELLOW})
  grid.set(TYPE_MIRROR, 1, level.y-1, {state =  1, color =  COLOR_CYAN})
  grid.set(TYPE_MIRROR, level.x, 11, {rotation = 1})
  
-- ADD UI ELEMENTS -- use menu.create() type functions, not yet defined.
end

function level.update(dt) -- dt is time since last update in seconds
-- CHECK WIN CONDITION -- use grid functions to check object states, update level.complete accordingly
  if grid.getState(16, 1)==2 and grid.getState(6, 9)==2 and grid.getState(23, 9)==2 and grid.getState(8, level.y)==2 and grid.getState(23, 11)==2 then level.complete = true end

-- OPTIONAL INTERACTIVE LEVEL FUNCTIONS -- direct modifications of object states do not trigger and UpdateObjectType flag! (Needs to be done manually)

end


return level

--[[

-- LIST OF NOTEWORTHY GLOBAL VARIABLES --

>>    Grid     << All operations to modify Grid should go through grid functions UNLESS you know what you're doing!
table with Grid[x][y] (within game boundary) contaning nil or an Object

>>  canvas_OL  << Love canvases, are drawn in love.draw()
>>  canvas_BG  << 
canvas for the Overlay and the Background respectively; dimensions are (TEXTURE_BASE_SIZE*level.x,TEXTURE_BASE_SIZE*level.y)
They are updated (and thus reset) before level.update() ONLY IF global flags UpdateOverlayFG (->sort of a lie but effect is the same from outside perspective) and UpdateBackgroundFG evaluate to true
(which would be impossible in a regular game without developer mode enabled);

>>  game_time  << (double) The current time since start of the game in seconds. Do not modify.

_________________________________________________________________

ENUMS for readability -- NO ASSIGNMENTS or else everything breaks
_________________________________________________________________

TYPE_WALL, TYPE_GLASS, TYPE_SOURCE, TYPE_RECEIVER, TYPE_MIRROR, TYPE_PWHEEL, TYPE_PRISM;
COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE, COLOR_BLACK;
Note that color 0 is treated the same as COLOR_BLACK (8); also note that a black receiver is not always in an active state, rather it is treated as an "any" receiver [to be implemented]

If unsure about the default configuration of each object, check objects.lua for the default objects.
Duly note that hasMask, rotateByEights and canChangeState are only defined within the default objects and not every single object.

_________________________________________________________________

FUN IDEAS
_________________________________________________________________
You can change level.x_val, level.y_val, level.drawbox_mode and call love.resize() (with 3rd argument dontResetUI true for efficiency) to emulate a screenshake!
Custom backgrounds with draw operations to background canvas!
Custom drawing on walls ith draw operations to overlay canvas!

]]
